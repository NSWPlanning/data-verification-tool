require 'data_quality'
require 'council_file_statistics'
require 'invalid_records'
require 'land_parcel_statistics'
class LocalGovernmentAreaRecordImportLog < ActiveRecord::Base

  belongs_to :local_government_area

  attr_accessible :local_government_area, :local_government_area_id,
    :data_quality, :council_file_statistics, :invalid_records,
    :land_parcel_statistics

  # Make sure each of these has a corresponding require line in this
  # files header.
  serialize :data_quality
  serialize :council_file_statistics
  serialize :invalid_records
  serialize :land_parcel_statistics

  include ImportLog

  def self.extra_attributes_for(importer)
    {:local_government_area_id => importer.local_government_area.id}
  end

  alias :original_importer_attributes :importer_attributes
  protected
  def importer_attributes
    original_importer_attributes.merge(
      :data_quality => importer.data_quality,
      :council_file_statistics => importer.council_file_statistics,
      :invalid_records => importer.invalid_records,
      :land_parcel_statistics => importer.land_parcel_statistics
    )
  end

end
