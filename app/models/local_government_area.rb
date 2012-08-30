class LocalGovernmentArea < ActiveRecord::Base
  has_paper_trail
  validates_uniqueness_of :name
  validates_presence_of :name
  attr_accessible :name, :alias
  attr_accessible :name, :alias, :user_ids, :as => :admin

  has_and_belongs_to_many :users
  has_many :land_and_property_information_records

  def to_s
    name
  end
end
