class LocalGovernmentAreaRecordImporter < Importer

  class DuplicateDpError              < StandardError ; end
  class InconsistentSpAttributesError < StandardError ; end
  class NotInLgaError                 < StandardError ; end
  class LgaFilenameMismatchError      < StandardError ; end
  class LgaFileUnparseableError       < StandardError ; end
  class LgaFileEmptyError             < StandardError ; end

  class LgaFileHeadersInvalidError < StandardError
    def initialize(headers = {}, record_count = 0)
      @headers = headers
      @record_count = record_count
    end

    def record_count
      @record_count
    end

    def headers
      @headers
    end
  end

  class LgaFirstBatchFailed < StandardError ; end

  attr_accessor :local_government_area

  delegate :delete_invalid_local_government_area_records,
    :invalid_record_count,
    :valid_record_count,
    :duplicate_dp_records,
    :mark_duplicate_dp_records_invalid,
    :mark_inconsistent_sp_records_invalid,
    :missing_dp_lpi_records,
    :missing_sp_lpi_records, :to => :local_government_area

  delegate *LocalGovernmentArea.statistics_set_names, :to => :local_government_area

  def initialize(filename, user, options = {})
    @invalid_records = 0
    @local_government_area = options[:local_government_area]
    super(filename, user)
  end

  def primary_lookup
    lga_record_lookup
  end

  def log_class
    LocalGovernmentAreaRecordImportLog
  end

  def data_file_class
    DVT::LGA::DataFile
  end

  def new_data_file
    data_file_class.new(filename, @local_government_area.name)
  end

  def data_file
    @data_file ||= new_data_file
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
      ar_record.save!(:validate => false)
      @invalid_records += 1
      raise e
    end
  end

  def import(batch_size = 1000)
    super(batch_size) do
      if batch_number == 1 &&
        (valid_file_rows > batch_size) &&
        (@invalid_records == batch_size)
        raise LgaFirstBatchFailed.new
      end
    end
  end

  def catchable_exceptions
    [
      LocalGovernmentAreaRecordLookup::RecordAlreadySeenError,
      ActiveRecord::RecordInvalid
    ]
  end

  def increment_exception_counters(exception)
    if exception.respond_to?(:record)
      record = exception.record

# Almost sure this is incorrect...
#      record.errors[:dp_plan_number].each do |error|
#        if error =~ /must begin with either DP or SP/
#          exception_counters[:invalid_title_reference] += 1
#        end
#      end
      exception_counters[:invalid_title_reference] += 1 if record.has_invalid_title_reference?

      exception_counters[:invalid_address] +=1 if record.has_address_errors?
      exception_counters[:missing_si_zone] +=1 if record.missing_si_zone?

    end
  end

  def target_class
    LocalGovernmentAreaRecord
  end

  def statistics_fields
    super + [:invalid_record_count, :valid_record_count]
  end

  def invalidate_duplicate_dp_records
    mark_duplicate_dp_records_invalid
    dp_list = duplicate_dp_records.map do |row|
      add_exception_to_base(
        DuplicateDpError.new("%s appears %d times" % [row[0], row[1]])
      )
      exception_counters[:duplicate_title_reference] += 1
      row[0]
    end    
  end

  def invalidate_inconsistent_sp_records
    mark_inconsistent_sp_records_invalid.each do |sp_number|
      add_exception_to_base(
        InconsistentSpAttributesError.new(
          "%s has inconsistent attributes" % [sp_number]
        )
      )
      exception_counters[:inconsistent_attributes] += 1
    end
  end

  # Adds base exceptions for each DP LPI record for which there is no
  # corresponding LGA record.
  def add_exceptions_for_missing_dp_lpi_records
    missing_dp_lpi_records.each do |lpi_record|
      add_exception_to_base(
        NotInLgaError.new(
          "'%s' is present in LPI database but not in this LGA" % [lpi_record]
        )
      )
    end
  end

  # Adds base exceptions for each SP LPI record for which there is no
  # corresponding LGA record.
  def add_exceptions_for_missing_sp_lpi_records
    missing_sp_lpi_records.each do |lpi_record|
      add_exception_to_base(
        NotInLgaError.new(
          "'%s' is present in LPI database but not in this LGA" % [lpi_record]
        )
      )
    end
  end

  # Queue an import for later processing.  data_file is expected to be an
  # ActionDispatch::Http::UploadedFile whose contents will be stored for
  # later processing.
  def self.enqueue(local_government_area, data_file, user)
    Rails.logger.info "Queueing #{data_file.original_filename} for #{local_government_area}. Uploaded by #{user} (#{user.id})."
    
    # Permanently store the uploaded data file
    stored_file_path = store_uploaded_file(
      data_file, target_directory(local_government_area)
    )

    # FIXME - This is called in config/initializers/queue_classic.rb, but
    # in production the connection is lost when Unicorn forks.  Reset it
    # here to ensure it is set.
    QC::Conn.connection = ActiveRecord::Base.connection.raw_connection

    QC.enqueue(
      'LocalGovernmentAreaRecordImporter.import',
      local_government_area.id, stored_file_path, user.id
    )

    Rails.logger.info "Finished queueing #{data_file.original_filename}"
  end

  # This method delegates to the instance method #import.  It is present
  # because the background job mechanism (queue_classic) cannot serialize
  # the ActiveRecord instances, only their ids.  So this method finds the
  # AR instances by id, initializes a new LocalGovernmentAreaRecordImporter
  # instance with these and calls #import on it.
  def self.import(local_government_area_id, filename, user_id, batch_size = 1000)
    Rails.logger.info "Starting import for #{filename}"
    
    local_government_area = LocalGovernmentArea.find(local_government_area_id)
    user = User.find(user_id)
    importer = new(filename, user, :local_government_area => local_government_area)
    importer.import(batch_size)

    Rails.logger.info "Finished import for #{filename}"
  end

  def self.store_uploaded_file(uploaded_file, target_directory)
    File.join(target_directory, uploaded_file.original_filename).tap do |target|
      FileUtils.cp uploaded_file.tempfile.path, target
    end
  end

  def self.target_directory(local_government_area)
    # Create a unique directory name under the lpi_data_file_directory prefixed
    # with the LGA id.  This ensures that if a file with the same name is
    # uploaded twice it will not overwrite the existing file.
    Dir.mktmpdir(
      local_government_area.id.to_s + '-',
      Rails.application.config.lpi_data_file_directory
    )
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

    lookup = lpi_by_lga_lookup_for_record(record)

    return nil if lookup.nil?

    if lookup.has_record?(record)
      return lookup.id_and_md5sum_for(record)[0]
    end
  end

  # Select which lookup to use based on the type of record
  def lpi_by_lga_lookup_for_record(record)
    if record.sp?
      return send(:sp_lpi_by_lga_lookup)
    elsif record.dp?
      return send(:dp_lpi_by_lga_lookup)
    end
  end

  def check_import_file_not_empty!
    unless valid_file_rows > 1
      raise LgaFileEmptyError.new("#{filename} is empty")
    end
  end

  # Check that the file being imported matches the LGA.  For example, the
  # filename for 'Camden' should be ehc_camden_YYYYMMDD.csv.
  #
  # If the LGA part of the filename differs, this method will raise an
  # LgaFilenameMismatchError
  def check_import_filename!
    got_lga_name = data_file.lga_name.downcase
    expected_lga_name = local_government_area.filename_component.downcase
    unless got_lga_name == expected_lga_name
      raise LgaFilenameMismatchError.new(
        "the file #{File.basename(filename)} is not a valid filename, #{got_lga_name} should be #{expected_lga_name}"
      )
    end
  end

  def check_import_file_headers!
    headers = new_data_file.header_difference
    unless headers.blank?
      raise LgaFileHeadersInvalidError.new(headers, valid_file_rows), headers.to_s
    end
  end

  def before_import
    check_import_file_not_empty!
    check_import_filename!
    check_import_file_headers!

    delete_invalid_local_government_area_records
  end

  def after_import
    invalidate_duplicate_dp_records
    invalidate_inconsistent_sp_records
    add_exceptions_for_missing_dp_lpi_records
    add_exceptions_for_missing_sp_lpi_records

    items = [
      :malformed,
      :invalid_title_reference,
      :duplicate_title_reference,
      :invalid_address,
      :missing_si_zone,
      :inconsistent_attributes
    ]

    local_government_area.invalid_records = InvalidRecords.new({}.tap { |hash|
      total = 0
      items.each { |item|
        amount = exception_counters[item]
        hash[item] = amount
        total += amount
      }
      hash[:total] =total
    })
  end

  protected

  def complete_import
    finish_import_with_state(:complete)
    LocalGovernmentAreaRecordImportMailer.complete(self).deliver
  end

  def dry_run
    begin
      new_data_file.each do |row|
        @valid_file_rows = valid_file_rows + 1
      end
    rescue CSV::MalformedCSVError, ArgumentError => e
      raise LgaFileUnparseableError.new, e.message
    end
  end

  def fail_import(exception)
    finish_import_with_state(:fail)
    Rails.logger.info exception.backtrace

    begin
      raise exception
    rescue LgaFilenameMismatchError, DVT::LGA::DataFile::InvalidFilenameError => e
      LocalGovernmentAreaRecordImportMailer.filename_incorrect(self, e).deliver
    rescue LgaFileUnparseableError => e
      LocalGovernmentAreaRecordImportMailer.unparseable(self, e).deliver
    rescue LgaFileEmptyError => e
      LocalGovernmentAreaRecordImportMailer.empty(self, e).deliver
    rescue LgaFileHeadersInvalidError => e
      LocalGovernmentAreaRecordImportMailer.header_errors(self, e).deliver
    rescue LgaFirstBatchFailed => e
      LocalGovernmentAreaRecordImportMailer.aborted(self, e).deliver
    rescue
      ImportMailer.import_failed(self, $!).deliver
    end
  end

end
