require 'spec_helper'

describe UsersController do

  let(:admin) { FactoryGirl.create(:admin_user) }

  before do
    login_user admin
  end

  it_should_behave_like "a resource controller for", User

end
