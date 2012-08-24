require 'spec_helper'

describe LocalGovernmentAreasController do

  include LibSpecHelpers

  let(:admin) { FactoryGirl.create(:admin_user) }

  before do
    login_user admin
  end

  it_should_behave_like "a resource controller for", LocalGovernmentArea

end
