require 'spec_helper'

describe UsersController do

  let(:admin) { FactoryGirl.create(:admin_user) }

  before do
    login_user admin
  end

  it_should_behave_like "a resource controller for", User

  describe '#admin' do

    let(:users) { mock("users") }

    before do
      User.stub(:with_roles).with(:admin) { users }
    end

    it 'returns the admin users' do
      get :admin
      subject.should have_page_title('Admin Users')
      assigns[:users].should == users
    end
  end

end
