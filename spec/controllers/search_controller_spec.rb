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

      context "common land parcel" do

        let!(:lpi_sp) {
          FactoryGirl.create :land_and_property_information_record,
            :title_reference => "//SP123",
            :local_government_area_id => lga.id
        }

        let!(:lga_sp_1) {
          FactoryGirl.create :local_government_area_record,
            :dp_lot_number => "1",
            :dp_plan_number => "SP123",
            :land_and_property_information_record => lpi_sp,
            :local_government_area => lga
        }

        let!(:lga_sp_2) {
          FactoryGirl.create :local_government_area_record,
            :dp_lot_number => "2",
            :dp_plan_number => "SP123",
            :land_and_property_information_record => lpi_sp,
            :local_government_area => lga
        }

        it "redirects to a if the user was specifically searching for it" do
          post :index, :filter => "//SP123"

          response.should be_redirect
        end

        it "lists results if the user was not specifically searching for it" do
          post :index, :filter => "SP123"

          response.should be_success
        end
      end

      context "other land parcel" do

        let!(:single_lgar) {
          FactoryGirl.create :local_government_area_record,
            :dp_lot_number => "1",
            :dp_plan_number => "DP4321",
            :local_government_area => lga
        }

        it "redirects if there was only one result" do
          post :index, :filter => "DP4321"

          response.should be_redirect
        end

        it "does not redirect if there are multiple results" do
          post :index, :filter => "DP123"

          response.should_not be_success
        end
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
