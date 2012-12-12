require 'importer'
class LandAndPropertyInformationImporter < Importer

  def primary_lookup
    lpi_lookup
  end

  def data_file_class
    DVT::LPI::DataFile
  end

  def catchable_exceptions
    [
      LandAndPropertyInformationLookup::RecordAlreadySeenError,
      LocalGovernmentAreaLookup::AliasNotFoundError,
      ActiveRecord::RecordInvalid
    ]
  end

  def target_class
    LandAndPropertyInformationRecord
  end

  def log_class
    LandAndPropertyInformationImportLog
  end

  def destroy_method
    :retire!
  end

  protected
  def extra_record_attributes(record)
    {
      :local_government_area_id => lga_lookup.find_id_from_lpi_alias(record.lga_name),
      :retired => false
    }
  end
end
