require 'spec_helper'

describe SearchController do

  let(:user)  { FactoryGirl.create(:user) }

  let(:lpi_record_1) {
    FactoryGirl.create :land_and_property_information_record,
      :lot_number => "123",
      :section_number => "456",
      :plan_label => "DP789",
      :title_reference => "123/456/DP789"
  }

  let(:lpi_record_2) {
    FactoryGirl.create :land_and_property_information_record,
      :lot_number => "789",
      :section_number => "012",
      :plan_label => "DP789",
      :title_reference => "798/012/DP789"
  }

  before do
    login_user user
  end

  describe '#search' do
    it "is a success" do
      post :index

      response.should be_success
    end

    it "assigns land property information records" do
      post :index, :filter => "//DP789"

      assigns[:land_title_to_records].should_not be_nil
    end

    it "assigns the relevant land property information records" do
      post :index, :filter => "//DP789"

      puts lpi_record_1.inspect
      puts lpi_record_2.inspect
      puts assigns[:land_title_to_records].inspect

      assigns[:land_title_to_records].keys.length.should eq 1
      assigns[:land_title_to_records].values.first.should eq lpi_record_1
    end
  end

end
