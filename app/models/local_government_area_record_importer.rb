class LocalGovernmentAreaRecordImporter < Importer

  class DuplicateDpError              < StandardError ; end
  class InconsistentSpAttributesError < StandardError ; end

  attr_accessor :local_government_area

  delegate :delete_invalid_local_government_area_records, :invalid_record_count,
    :valid_record_count, :duplicate_dp_records,
    :mark_duplicate_dp_records_invalid, :mark_inconsistent_sp_records_invalid,
    :to => :local_government_area

  def primary_lookup
    lga_record_lookup
  end

  def log_class
    LocalGovernmentAreaRecordImportLog
  end

  def data_file_class
    DVT::LGA::DataFile
  end

  def store_seen_records?
    true
  end

  # This overrides the base class implementation.  Instead of just failing save
  # if the record is invalid, save the record bypassing validation.
  def create_record!(record)
    @created += 1
    begin
      ar_record = target_class.new(record_attributes(record))
      ar_record.save!
      return ar_record
    rescue ActiveRecord::RecordInvalid => e
      ar_record.is_valid = false
      ar_record.save!(:validate => false)
      raise e
    end
  end


  def catchable_exceptions
    [
      LocalGovernmentAreaRecordLookup::RecordAlreadySeenError,
      ActiveRecord::RecordInvalid
    ]
  end

  def target_class
    LocalGovernmentAreaRecord
  end

  def statistics_fields
    super + [:invalid_record_count, :valid_record_count]
  end

  def invalidate_duplicate_dp_records
    dp_list = duplicate_dp_records.map do |row|
      add_exception_to_base(
        DuplicateDpError.new("%s appears %d times" % [row[0], row[1]])
      )
      row[0]
    end
    mark_duplicate_dp_records_invalid
  end

  def invalidate_inconsistent_sp_records
    mark_inconsistent_sp_records_invalid.each do |sp_number|
      add_exception_to_base(
        InconsistentSpAttributesError.new(
          "%s has inconsistent attributes" % [sp_number]
        )
      )
    end
  end

  # Queue an import for later processing.  data_file is expected to be an
  # ActionDispatch::Http::UploadedFile whose contents will be stored for
  # later processing.
  def self.enqueue(local_government_area, data_file, user)
    # Permanently store the uploaded data file
    stored_file_path = store_uploaded_file(data_file, target_directory)

    # FIXME - This is called in config/initializers/queue_classic.rb, but
    # in production the connection is lost when Unicorn forks.  Reset it
    # here to ensure it is set.
    QC::Conn.connection = ActiveRecord::Base.connection.raw_connection

    QC.enqueue(
      'LocalGovernmentAreaRecordImporter.import',
      local_government_area.id, stored_file_path, user.id
    )
  end

  # This method delegates to the instance method #import.  It is present
  # because the background job mechanism (queue_classic) cannot serialize
  # the ActiveRecord instances, only their ids.  So this method finds the
  # AR instances by id, initializes a new LocalGovernmentAreaRecordImporter
  # instance with these and calls #import on it.
  def self.import(local_government_area_id, filename, user_id)
    local_government_area = LocalGovernmentArea.find(local_government_area_id)
    user = User.find(user_id)
    importer = new(filename, user)
    importer.local_government_area = local_government_area
    importer.import
  end

  def self.store_uploaded_file(uploaded_file, target_directory)
    File.join(target_directory, uploaded_file.original_filename).tap do |target|
      FileUtils.cp uploaded_file.tempfile.path, target
    end
  end

  def self.target_directory
    Rails.application.config.lpi_data_file_directory
  end

  def extra_record_attributes(record)
    {
      :land_and_property_information_record_id => find_lpi_id_for(record),
      :local_government_area_id => local_government_area.id
    }
  end

  def find_lpi_id_for(record)
    unless local_government_area
      raise RuntimeError,
        'local_government_area must be set before calling LocalGovernmentAreaRecordImporter#find_lpi_id_for(record)'
    end
    if lpi_by_lga_lookup.has_record?(record)
      lpi_by_lga_lookup.id_and_md5sum_for(record)[0]
    end
  end

  def before_import
    delete_invalid_local_government_area_records
  end

  def after_import
    invalidate_duplicate_dp_records
    invalidate_inconsistent_sp_records
  end
end
