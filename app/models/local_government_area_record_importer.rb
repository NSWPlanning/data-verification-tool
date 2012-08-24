class LocalGovernmentAreaRecordImporter < Importer

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

  def target_class
    LocalGovernmentAreaRecord
  end

  # Queue an import for later processing.  data_file is expected to be an
  # ActionDispatch::Http::UploadedFile whose contents will be stored for
  # later processing.
  def self.enqueue(local_government_area, data_file, user)
    # Permanently store the uploaded data file
    stored_file_path = store_uploaded_file(data_file, target_directory)
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

end
