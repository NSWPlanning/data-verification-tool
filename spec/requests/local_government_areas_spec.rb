require 'spec_helper'

describe "Local Goverment Area" do

  let(:admin_user)  { FactoryGirl.create :admin_user }

  describe "create an LGA" do

    specify do

      sign_in_as admin_user

      click_on 'LGAs'
      click_on 'Create new local government area'

      fill_in 'Name', :with => 'New LGA name'
      click_on 'Create LGA'

      page.should have_content('New LGA name')

    end
  end

  describe "show the LGA list" do

    let!(:local_government_area1) {
      FactoryGirl.create :local_government_area
    }
    let!(:local_government_area2) {
      FactoryGirl.create :local_government_area
    }

    specify do
      sign_in_as admin_user

      click_on 'LGAs'

      page.should have_content(local_government_area1.to_s)
      page.should have_content(local_government_area2.to_s)
    end

  end

  describe "showing an individual LGA" do

    let!(:local_government_area)  { FactoryGirl.create :local_government_area }

    specify do
      sign_in_as admin_user

      click_on 'LGAs'
      click_on local_government_area.name

      header.should have_content(local_government_area.name)
    end

  end

  describe "editing an LGA" do

    let!(:local_government_area)  {
      FactoryGirl.create :local_government_area, :name => 'Old Name' }

    specify do
      sign_in_as admin_user

      click_on 'LGAs'
      local_government_area_details_for(local_government_area).click_on 'Edit'

      fill_in 'Name', :with => 'New Name'
      click_on 'Update LGA'

      local_government_area_details_for(local_government_area).should have_content('New Name')
    end
  end

  def local_government_area_details_for(local_government_area)
    find("#local_government_area_#{local_government_area.id}")
  end

end
