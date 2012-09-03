class LandAndPropertyInformationRecord < ActiveRecord::Base
  attr_accessible :cadastre_id, :end_date, :last_update, :lga_name,
    :lot_number, :modified_date, :plan_label, :section_number,
    :start_date, :title_reference, :md5sum, :local_government_area_id
  validate :cadastre_id, :scope => :local_government_area_id,
    :uniqueness => true
  validates :cadastre_id, :lga_name, :title_reference, :md5sum,
    :presence => true
end
