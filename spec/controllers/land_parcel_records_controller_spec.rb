require 'spec_helper'

describe LandParcelRecordsController do

  let!(:lpi_sp) {
    FactoryGirl.create :land_and_property_information_record,
      :title_reference => "//SP123"
  }

  describe "#show" do

    it "should be a success" do
      get :show, :id => "//SP123"

      response.should be_success
    end

    it "should raise an error for an invalid id" do
      expect {
        get :show, :id => "//SP321"
      }.to raise_error LandParcelRecord::RecordNotFound
    end

  end

end
