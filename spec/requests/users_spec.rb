require 'spec_helper'

describe "User management" do

  let(:admin_user)  { FactoryGirl.create :admin_user }

  describe "creating a user" do

    specify do

      sign_in_as admin_user
      
      click_on 'Users'
      click_on 'Create new user'

      fill_in 'Name',                   :with => 'Joe User'
      fill_in 'Email',                  :with => 'joe@example.com'
      fill_in 'Password',               :with => 'password'
      fill_in 'Password confirmation',  :with => 'password'

      click_on 'Create User'

      page.should have_content("Joe User <joe@example.com>")

    end

  end

  describe "showing the user list" do

    let!(:user1)  { FactoryGirl.create :user }
    let!(:user2)  { FactoryGirl.create :user }

    specify do
      sign_in_as admin_user

      click_on 'Users'

      page.should have_content(user1.to_s)
      page.should have_content(user2.to_s)
    end

  end

  describe "showing only admin users" do

    let!(:user)   { FactoryGirl.create :user }

    specify do
      sign_in_as admin_user

      click_on 'Users'
      click_on 'Admin users'

      page.should_not have_content(user.to_s)
      page.should have_content(admin_user.to_s)
    end

  end


  describe "showing an individual user" do

    let!(:user)  { FactoryGirl.create :user }

    specify do
      sign_in_as admin_user

      click_on 'Users'
      click_on user.email

      header.should have_content(user.to_s)
    end

  end

  describe "editing a user" do
    let!(:user)  { FactoryGirl.create :user, :email => 'olduser@example.com' }

    specify do
      sign_in_as admin_user

      click_on 'Users'
      user_details_for(user).click_on 'Edit'

      fill_in 'Email', :with => 'newuser@example.com'
      click_on 'Update User'

      user_details_for(user).should have_content('newuser@example.com')
    end
  end

  describe "add user to an LGA" do

    let!(:user) { FactoryGirl.create :user }
    let!(:lga)  {
      FactoryGirl.create :local_government_area, :name => 'Bogan Shire'
    }

    specify do
      sign_in_as admin_user

      user.should_not be_member_of_local_government_area(lga)

      click_on 'Users'
      click_on user.email

      local_government_area_list.should have_content(
        'This user is not linked to any LGAs'
      )
      user_details_for(user).click_on 'Edit'

      select 'Bogan Shire', :from => 'Local government areas'
      click_on 'Update User'

      local_government_area_list.should have_content('Bogan Shire')
    end

  end

  describe "manage roles" do

    let!(:user)  { FactoryGirl.create :user }

    specify do

      sign_in_as admin_user

      click_on 'Users'
      user_details_for(user).should_not have_content('admin')

      user_details_for(user).click_on 'Edit'
      check 'Admin'
      click_on 'Update User'

      user_details_for(user).should have_content('admin')

      user_details_for(user).click_on 'Edit'
      uncheck 'Admin'
      click_on 'Update User'

      user_details_for(user).should_not have_content('admin')

    end

  end

  def user_details_for(user)
    find("#user_#{user.id}")
  end

  def local_government_area_list
    find('#local_government_areas')
  end

end
