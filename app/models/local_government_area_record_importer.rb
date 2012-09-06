class LocalGovernmentAreaRecordImporter < Importer

  class DuplicateDpError < StandardError ; end

  attr_accessor :local_government_area

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

  def invalidate_duplicate_dp_records
    dp_list = duplicate_dp_records.map do |row|
      add_exception_to_base(
        DuplicateDpError.new("%s appears %d times" % [row[0], row[1]])
      )
      row[0]
    end
    mark_duplicate_dp_records_invalid
  end

  # Returns a list of all of the duplicate DP records for an LGA as an
  # array of arrays:
  #
  #   # DP1234 appears 5 times, DP6789 appears 10 times for the LGA
  #   [
  #     ['DP1234', '5'],
  #     ['DP6789', '10'],
  #   ]
  def duplicate_dp_records
    target_class.connection.query(%{
      SELECT dp_plan_number, COUNT(dp_plan_number) AS duplicate_count
      FROM local_government_area_records
      WHERE dp_plan_number LIKE 'DP%%' AND local_government_area_id = %d
      GROUP BY dp_plan_number
      HAVING (COUNT(dp_plan_number) > 1)
    } % [local_government_area.id])
  end

  def mark_duplicate_dp_records_invalid
    target_class.connection.query(%{
      UPDATE local_government_area_records
      SET is_valid = FALSE
      WHERE dp_plan_number IN (
        SELECT dp_plan_number
        FROM local_government_area_records
        WHERE dp_plan_number LIKE 'DP%%' AND local_government_area_id = %d
        GROUP BY dp_plan_number
        HAVING (COUNT(dp_plan_number) > 1)
      )
      AND local_government_area_id = %d
    } % [local_government_area.id, local_government_area.id])
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
    lpi_id = if lpi = find_lpi_for_record(record)
               lpi.id
             else
               nil
             end
    {
      :land_and_property_information_record_id => lpi_id,
      :local_government_area_id => local_government_area.id
    }
  end

  def find_lpi_for_record(record)
    if local_government_area.nil?
      raise RuntimeError,
        'local_government_area must be set on LocalGovernmentAreaRecordImporter'
    end
    local_government_area.find_land_and_property_information_record_by_title_reference(
      record.title_reference
    )
  end

  def after_import
    invalidate_duplicate_dp_records
  end
end
