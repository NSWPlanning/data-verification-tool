class NonStandardInstrumentationZoneImportLog < ActiveRecord::Base

  belongs_to :local_government_area

  attr_accessible :local_government_area, :local_government_area_id

  scope :successful, where(:success => true)

  include ImportLog

  def self.extra_attributes_for(importer)
    {:local_government_area_id => importer.local_government_area.id}
  end

end
