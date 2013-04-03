class NonStandardInstrumentationZoneImporter < Importer

  class NsiFilenameMismatchError      < StandardError ; end
  class NsiFileUnparseableError       < StandardError ; end
  class NsiFileEmptyError             < StandardError ; end

  class NsiFileHeadersInvalidError < StandardError
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

  attr_accessor :local_government_area

  def initialize(filename, user, options = {})
    @invalid_records = 0
    @local_government_area = options[:local_government_area]
    super(filename, user)
  end

  def data_file_class
    DVT::NSI::DataFile
  end

  def catchable_exceptions
    [
      LocalGovernmentAreaLookup::AliasNotFoundError,
      ActiveRecord::RecordInvalid
    ]
  end

  def log_class
    NonStandardInstrumentationZoneImportLog
  end

  def new_data_file
    data_file_class.new(filename, @local_government_area.name)
  end

  def data_file
    @data_file ||= new_data_file
  end

  def primary_lookup
    nsi_record_lookup
  end

  def target_class
    NonStandardInstrumentationZone
  end

  def self.target_directory(local_government_area)
    # Create a unique directory name under the nsi_data_file_directory prefixed
    # with the LGA id.  This ensures that if a file with the same name is
    # uploaded twice it will not overwrite the existing file.
    Dir.mktmpdir(
      local_government_area.id.to_s + '-',
      Rails.application.config.nsi_data_file_directory
    )
  end

  def extra_record_attributes(record)
    {
      :local_government_area_id => local_government_area.id
    }
  end

  def self.store_uploaded_file(uploaded_file, target_directory)
    File.join(target_directory, uploaded_file.original_filename).tap do |target|
      FileUtils.cp uploaded_file.tempfile.path, target
    end
  end

  # Queue an import for later processing.  data_file is expected to be an
  # ActionDispatch::Http::UploadedFile whose contents will be stored for
  # later processing.
  def self.enqueue(local_government_area, data_file, user)
    # Permanently store the uploaded data file
    stored_file_path = store_uploaded_file(
      data_file, target_directory(local_government_area)
    )

    # FIXME - This is called in config/initializers/queue_classic.rb, but
    # in production the connection is lost when Unicorn forks.  Reset it
    # here to ensure it is set.
    QC::Conn.connection = ActiveRecord::Base.connection.raw_connection

    QC.enqueue(
      'NonStandardInstrumentationZoneImporter.import',
      local_government_area.id, stored_file_path, user.id
    )
  end

  def check_import_file_not_empty!
    unless valid_file_rows > 1
      raise NsiFileEmptyError.new("#{filename} is empty")
    end
  end

  def check_import_filename!
    got_lga_name = data_file.lga_name.downcase
    expected_lga_name = local_government_area.filename_component.downcase
    unless got_lga_name == expected_lga_name
      raise NsiFilenameMismatchError.new(
        "the file #{File.basename(filename)} is not a valid filename, #{got_lga_name} should be #{expected_lga_name}"
      )
    end
  end

  def check_import_file_headers!
    headers = new_data_file.header_difference
    unless headers.blank?
      raise NsiFileHeadersInvalidError.new(headers, valid_file_rows), headers.to_s
    end
  end

  def before_import
    check_import_file_not_empty!
    check_import_filename!
    check_import_file_headers!
  end

  def self.import(local_government_area_id, filename, user_id, batch_size = 1000)
    local_government_area = LocalGovernmentArea.find(local_government_area_id)
    user = User.find(user_id)
    importer = new(filename, user, :local_government_area => local_government_area)
    importer.import(batch_size)
  end

  def dry_run
    begin
      new_data_file.each do |row|
        @valid_file_rows = valid_file_rows + 1
      end
    rescue CSV::MalformedCSVError, ArgumentError => e
      raise NsiFileUnparseableError.new, e.message
    end
  end

  def fail_import(exception)
    finish_import_with_state(:fail)
    Rails.logger.info exception.backtrace

    begin
      raise exception
    rescue NsiFilenameMismatchError, DVT::NSI::DataFile::InvalidFilenameError => e
      NonStandardInstrumentationZoneImportMailer.filename_incorrect(self, e).deliver
    rescue NsiFileUnparseableError => e
      NonStandardInstrumentationZoneImportMailer.unparseable(self, e).deliver
    rescue NsiFileEmptyError => e
      NonStandardInstrumentationZoneImportMailer.empty(self, e).deliver
    rescue NsiFileHeadersInvalidError => e
      NonStandardInstrumentationZoneImportMailer.header_errors(self, e).deliver
    rescue
      ImportMailer.import_failed(self, $!).deliver
    end
  end

end
