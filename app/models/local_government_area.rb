class LocalGovernmentArea < ActiveRecord::Base
  has_paper_trail
  validates_uniqueness_of :name
  validates_presence_of :name
  attr_accessible :name, :as => :admin

  def to_s
    name
  end
end
