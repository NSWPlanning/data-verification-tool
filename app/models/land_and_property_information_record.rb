class LandAndPropertyInformationRecord < ActiveRecord::Base
  attr_accessible :cadastre_id, :end_date, :last_update, :lga_name,
    :lot_number, :modified_date, :plan_label, :section_number,
    :start_date, :title_reference, :md5sum
  validate :cadastre_id, :uniqueness => true
  validates :cadastre_id, :lga_name, :title_reference, :md5sum,
    :presence => true
end
