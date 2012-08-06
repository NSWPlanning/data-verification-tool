require 'spec_helper'

describe 'Unauthenticated actions' do

  let!(:user)  {
    FactoryGirl.create :admin_user, :email => 'foo@example.com', :password => 'password'
  }

  describe 'log in' do
    specify do
      visit '/'

      fill_in 'Email',    :with => 'foo@example.com'
      fill_in 'Password', :with => 'password'
      click_on 'Log in'

      page.should have_content('Log out')
    end
  end

  describe 'forgot password' do
    specify do
      visit '/'
      click_on 'Forgot password?'

      fill_in 'Email', :with => 'foo@example.com'
      click_on 'Send password reset instructions'

      page.should have_content('Password reset instructions have been sent to your email address')

      emails_for('foo@example.com').length.should == 1
      email = emails_for('foo@example.com').first
      email.subject.should == 'Password reset instructions'

      reset_url = URI.extract(email.body.to_s).first
      visit reset_url
      page.should have_content('Reset password')
      fill_in 'Password', :with => 'newpassword'
      fill_in 'Password confirmation', :with => 'newpassword'
      click_on 'Reset password'

      page.should have_content('Your password has been updated')

    end
  end

  def emails_for(address)
    ActionMailer::Base.deliveries.select do |delivery|
      delivery.to.include? address
    end
  end
end
