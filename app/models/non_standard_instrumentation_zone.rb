class NonStandardInstrumentationZone < ActiveRecord::Base

  belongs_to :local_government_area

  attr_accessible :transaction_type,
    :md5sum,
    :local_government_area_id,
    :date_of_update,
    :lep_nsi_zone,
    :lep_si_zone,
    :lep_name,
    :council_id

  validates_presence_of :date_of_update,
    :council_id,
    :md5sum

end
