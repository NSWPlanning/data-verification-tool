class LocalGovernmentArea < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_presence_of :name
  attr_accessible :name

  def to_s
    name
  end
end
