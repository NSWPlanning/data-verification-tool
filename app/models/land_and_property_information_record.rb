class LandAndPropertyInformationRecord < ActiveRecord::Base

  include RecordSearchHelper

  attr_accessible :cadastre_id,
    :end_date,
    :last_update,
    :lga_name,
    :lot_number,
    :modified_date,
    :plan_label,
    :section_number,
    :start_date,
    :title_reference,
    :md5sum,
    :local_government_area_id,
    :retired

  validate :cadastre_id,
    :scope => :local_government_area_id,
    :uniqueness => true

  validates :cadastre_id, :lga_name, :title_reference, :md5sum,
    :presence => true

  scope :retired, where(:retired => true)

  scope :active, where(:retired => false)



  def retire!
    self.retired = true
    save!
  end

  def common_property?
    title_reference.starts_with?("//SP")
  end

  def self.search(filter, conditions = {})
    super(filter, conditions, :plan_label, :section_number, :lot_number)
  end

end
