class NonStandardInstrumentationZoneImportLog < ActiveRecord::Base

  belongs_to :local_government_area

  attr_accessible :local_government_area, :local_government_area_id

  scope :successful, where(:success => true)

  def log_type
    :non_standard_instrumentation_zone
  end

  include ImportLog

  def self.extra_attributes_for(importer)
    {:local_government_area_id => importer.local_government_area.id}
  end

end
