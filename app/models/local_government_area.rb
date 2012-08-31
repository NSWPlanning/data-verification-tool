class LocalGovernmentArea < ActiveRecord::Base
  has_paper_trail
  validates_uniqueness_of :name
  validates_presence_of :name
  attr_accessible :name, :alias
  attr_accessible :name, :alias, :user_ids, :as => :admin

  has_and_belongs_to_many :users
  has_many :land_and_property_information_records
  has_many :local_government_area_records

  def to_s
    name
  end

  def find_land_and_property_information_record_by_title_reference(title_reference)
    land_and_property_information_records.find_by_title_reference(title_reference)
  end
end
