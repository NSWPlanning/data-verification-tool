class NonStandardInstrumentationZoneImporter < Importer

  attr_accessor :local_government_area

  def initialize(filename, user, options = {})
    @invalid_records = 0
    @local_government_area = options[:local_government_area]
    super(filename, user)
  end

  def data_file_class
    DVT::NSI::DataFile
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

  def self.import(local_government_area_id, filename, user_id, batch_size = 1000)
    local_government_area = LocalGovernmentArea.find(local_government_area_id)
    user = User.find(user_id)
    importer = new(filename, user, :local_government_area => local_government_area)
    importer.import(batch_size)
  end

end
