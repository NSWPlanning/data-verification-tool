class User < ActiveRecord::Base
  authenticates_with_sorcery!
  has_paper_trail
  attr_accessible :email, :password, :password_confirmation
  attr_accessible :email, :password, :password_confirmation, :admin,
                  :local_government_area_ids, :as => :admin
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email

  has_and_belongs_to_many :local_government_areas

  def to_s
    email
  end

  def member_of_local_government_area?(lga_or_id)
    id = lga_or_id.respond_to?(:id) ? lga_or_id.id : lga_or_id
    local_government_area_ids.include? id
  end
end
