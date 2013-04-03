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
    :lep_si_zone,
    :md5sum

  def local_government_area_record
    LocalGovernmentAreaRecord.where({
      :local_government_area_id => self.local_government_area_id,
      :council_id => self.council_id
    }).first
  end

end
