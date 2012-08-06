class User < ActiveRecord::Base
  authenticates_with_sorcery!
  has_paper_trail

  # If modifying this, only ever APPEND to the :as array
  bitmask :roles, :zero_value => :none, :as => [:admin]

  attr_accessible :email, :password, :password_confirmation, :name
  attr_accessible :email, :password, :password_confirmation, :name, :admin,
                  :local_government_area_ids, :roles, :as => :admin
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates :email, :presence => true, :uniqueness => true, :email => true
  validates_presence_of :name

  has_and_belongs_to_many :local_government_areas

  def to_s
    "%s <%s>" % [name, email]
  end

  def member_of_local_government_area?(lga_or_id)
    id = lga_or_id.respond_to?(:id) ? lga_or_id.id : lga_or_id
    local_government_area_ids.include? id
  end

  def admin?
    roles?(:admin)
  end

end
