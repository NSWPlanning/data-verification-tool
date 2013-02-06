require 'spec_helper'

describe SearchController do

  let(:user)  { FactoryGirl.create(:user) }

  let(:lpi_record) { FactoryGirl.create :land_and_property_information_record }

  before do
    login_user user
  end

  describe '#search' do
    it "is a success" do
      post :index

      response.should be_success
    end

    it "assigns land property information records" do
      post :index, :filter => "//#{lpi_record.plan_label}"

      assigns[:lpi_records].should_not be_nil
    end

    it "assigns the relevant land property information records" do
      post :index, :filter => "//#{lpi_record.plan_label}"

      assigns[:lpi_records].count.should eq 1
      assigns[:lpi_records].first.should eq lpi_record
    end
  end

end
