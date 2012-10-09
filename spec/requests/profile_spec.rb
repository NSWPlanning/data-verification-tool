require 'spec_helper'

describe 'Profile management' do

  let!(:user) { FactoryGirl.create(:user, :name => 'User Name') }

  specify 'editing my profile' do

    sign_in_as user

    click_on 'Profile'

    fill_in 'Name', :with => 'New User Name'
    click_on 'Update profile'

    user.reload
    user.name.should == 'New User Name'

    page.should have_content('Profile updated')

  end
end
