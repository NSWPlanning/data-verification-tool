require 'spec_helper'

describe SearchController do

  let!(:lga) {
    FactoryGirl.create :local_government_area
  }

  let!(:other_lga) {
    FactoryGirl.create :local_government_area
  }

  let(:admin_user) { FactoryGirl.create(:admin_user) }

  let(:normal_user) {
    user = FactoryGirl.build(:user)
    user.local_government_areas.push lga
    user.save!
    user
  }

  let(:lpir) {
    FactoryGirl.create :land_and_property_information_record,
      :lot_number => "1",
      :plan_label => "DP123",
      :title_reference => "1//DP123",
      :local_government_area_id => lga.to_param
  }

  let!(:lgar) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "1",
      :dp_plan_number => "DP123",
      :local_government_area => lga,
      :land_and_property_information_record => lpir
  }

  let!(:other_lgar) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "1",
      :dp_plan_number => "DP321",
      :local_government_area => other_lga
  }

  let!(:other_lgar_2) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "2",
      :dp_plan_number => "DP123",
      :local_government_area => other_lga
  }

  describe '#search' do

    context "user is not an admin" do
      before do
        login_user normal_user
      end

      it "is a success" do
        post :index

        response.should be_success
      end

      it "assigns land property information records" do
        post :index, :filter => "//DP123"

        assigns[:land_parcel_records].should_not be_nil
      end

      it "assigns the relevant land property information records" do
        post :index, :filter => "//DP123"

        assigns[:land_parcel_records].count.should eq 1
      end

      it "does not assign records for lgas the user is not a member for" do
        post :index, :filter => "DP321"

        assigns[:land_parcel_records].blank?.should be_true
      end
    end

    context "user is an admin" do
      before do
        login_user admin_user
      end

      it "is a success" do
        post :index

        response.should be_success
      end

      it "assigns land property information records" do
        post :index, :filter => "//DP123"

        assigns[:land_parcel_records].should_not be_nil
      end

      it "assigns the relevant land property information records" do
        post :index, :filter => "//DP123"

        assigns[:land_parcel_records].count.should eq 2
      end

    end

  end
end
