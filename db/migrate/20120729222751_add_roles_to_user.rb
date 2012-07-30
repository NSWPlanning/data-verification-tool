class AddRolesToUser < ActiveRecord::Migration

  class User < ActiveRecord::Base
    bitmask :roles, :as => [:admin]
  end

  def up
    add_column :users, :roles, :integer
    User.reset_column_information
    User.all.each do |user|
      user.roles << :admin if user.admin?
      user.save!
    end
    remove_column :users, :admin
  end

  def down
    add_column :users, :admin, :boolean, :default => false
    User.reset_column_information
    User.all.each do |user|
      user.admin = true if user.roles?(:admin)
      user.save!
    end
    remove_column :users, :roles
  end
end
