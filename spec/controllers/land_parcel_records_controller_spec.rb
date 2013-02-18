require 'spec_helper'

describe LandParcelRecordsController do

  let(:admin) { FactoryGirl.create(:admin_user) }

  let!(:lpi_sp) {
    FactoryGirl.create :land_and_property_information_record,
      :title_reference => "//SP123"
  }

  let!(:lga) {
    FactoryGirl.create :local_government_area
  }

  let!(:lgar) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "1",
      :dp_plan_number => "DP123",
      :local_government_area => lga
  }

  let(:normal_user) {
    user = FactoryGirl.build(:user)
    user.local_government_areas.push lga
    user.save!
    user
  }

  describe "#show" do

    context "user is an admin" do
      before do
        login_user admin
      end

      it "should be a success" do
        get :show, :id => "//SP123"

        response.should be_success
      end

      it "should render a 404 error for an invalid title reference" do
        expect {
          get :show, :id => "//SP321"
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "user is not an admin" do
      before do
        login_user normal_user
      end

      it "should redirect the users without access to the root page" do
        get :show, :id => "//SP123"

        response.should redirect_to root_path
      end

      it "should be a success if the user is part of the lga" do
        get :show, :id => "1//DP123"

        response.should be_success
      end

      it "should render a 404 error for an invalid title reference" do
        expect {
          get :show, :id => "//SP321"
        }.to raise_error ActiveRecord::RecordNotFound
      end
    end

  end

end
