require 'spec_helper'

describe LandParcelRecord do

  let!(:lga) { FactoryGirl.create :local_government_area }

  let!(:lpi_only_in_lpi) {
    FactoryGirl.create :land_and_property_information_record,
      :title_reference => "//DP666"
  }

  let!(:lga_only_in_lga) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "1",
      :dp_plan_number => "DP123",
      :lep_si_zone => "B3",
      :land_area => "100",
      :frontage => "100",
      :if_heritage_item => "Heritage Item",
      :acid_sulfate_soil_class => "3"
  }

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

  let!(:lpi_shared_inconsistent) {
    FactoryGirl.create :land_and_property_information_record,
      :title_reference => "//SP1800"
  }

  let!(:sp1_shared_inconsistent) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "1",
      :dp_plan_number => "SP1800",
      :if_mine_subsidence => "Yes",
      :if_acid_sulfate_soil => "Yes",
      :if_flood_control_lot => "No",
      :local_government_area => lga,
      :land_and_property_information_record => lpi_shared_inconsistent
  }

  let!(:sp2_shared_inconsistent) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "2",
      :dp_plan_number => "SP1800",
      :if_mine_subsidence => "No",
      :if_acid_sulfate_soil => "Yes",
      :if_flood_control_lot => "Yes",
      :local_government_area => lga,
      :land_and_property_information_record => lpi_shared_inconsistent
  }

  let!(:sp3_shared_inconsistent) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "3",
      :dp_plan_number => "SP1800",
      :if_mine_subsidence => "Yes",
      :if_acid_sulfate_soil => "No",
      :if_flood_control_lot => "Yes",
      :local_government_area => lga,
      :land_and_property_information_record => lpi_shared_inconsistent
  }

  describe '#initialize' do

    context "invalid title reference" do
      it "raises a record not found error, if no record could be found" do
        expect {
          LandParcelRecord.new("invalid_title_reference")
        }.to raise_error LandParcelRecord::RecordNotFound
      end
    end

    context "valid title reference" do
      context "strata plot" do
        context "common strata plot" do
          let!(:lpr) { LandParcelRecord.new("//SP123") }

          it "assigns lga records for a common strata plot" do
            lpr.lga_records.should_not be_nil
          end

          it "assigns the correct plots for the strata plot" do
            lpr.lga_records.should include(lga_sp_1, lga_sp_2)
          end
        end

        context "specific strata plot" do
          let!(:lpr) { LandParcelRecord.new("1//SP123") }

          it "assigns the correct lpi record" do
            lpr.lpi_record.should eq lpi_sp
          end

          it "assigns the correct lga_record" do
            lpr.lga_record.should eq lga_sp_1
          end
        end
      end
    end
  end

  describe '#title_reference' do
    let!(:lpr) { LandParcelRecord.new("//SP123") }

    it "should equal the instantiated value" do
      lpr.title_reference.should eq "//SP123"
    end
  end

  describe '#in_lpi?' do
    it "should be true if the parcel is in the lpi records" do
      lpr = LandParcelRecord.new("//SP123")

      lpr.in_lpi?.should be_true
    end

    it "should be false if the parcel is not in the lpi records" do
      lpr = LandParcelRecord.new("1//DP123")

      lpr.in_lpi?.should be_false
    end
  end

  describe '#in_lga?' do
    it "should be true if the parcel is in the lga records" do
      lpr = LandParcelRecord.new("1//DP123")

      lpr.in_lga?.should be_true
    end

    it "should be false if the parcel is not in the lga records" do
      lpr = LandParcelRecord.new("//DP666")

      lpr.in_lga?.should be_false
    end
  end

  describe '#is_sp?' do
    it "should be true if the parcel is a common sp plot" do
      lpr = LandParcelRecord.new("//SP123")

      lpr.is_sp?.should be_true
    end

    it "should be true if the parcel is a sp plot" do
      lpr = LandParcelRecord.new("1//SP123")

      lpr.is_sp?.should be_true
    end

    it "should not be true if the parcel is a normal land plot" do
      lpr = LandParcelRecord.new("1//DP123")

      lpr.is_sp?.should_not be_true
    end
  end

  describe '#common_property?' do
    it "should be true if the parcel is for a common strata plot" do
      lpr = LandParcelRecord.new("//SP123")

      lpr.common_property?.should be_true
    end

    it "should not be true if the parcel is for a common strata plot" do
      lpr = LandParcelRecord.new("1//SP123")

      lpr.common_property?.should be_false
    end

    it "should not be true if the parcel is for dp plot" do
      lpr = LandParcelRecord.new("1//DP123")

      lpr.common_property?.should be_false
    end
  end

  describe '#valid?' do

    it "should be valid if all of the lga records are valid" do
      lpr = LandParcelRecord.new("//SP123")

      lpr.valid?.should be_true
    end

    it "should not be valid if any of the lga records are valid" do
      lpr = LandParcelRecord.new("//DP666")

      lpr.valid?.should be_false
    end

  end

  describe '#errors' do

    let!(:lga_error_1) { FactoryGirl.create :local_government_area }

    let!(:lga_error_2) { FactoryGirl.create :local_government_area }

    let!(:lpi_error_sp) {
      FactoryGirl.create :land_and_property_information_record,
        :title_reference => "//SP696"
    }

    let!(:lga_error_sp_1) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "1",
        :dp_plan_number => "SP696",
        :land_and_property_information_record => lpi_sp,
        :local_government_area => lga_error_1
    }

    let!(:lga_error_sp_2) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "1",
        :dp_plan_number => "SP696",
        :land_and_property_information_record => lpi_sp,
        :local_government_area => lga_error_2
    }

    it "should add an error if there are multiple LGA ids for the records" do
      lpr = LandParcelRecord.new("1//SP696")
      lpr.valid?.should be_false

      lpr.errors.keys.should include :in_more_than_one_lga
    end

    context "where the land parcel is a duplicate dp record" do
      let!(:lga_dp_duplicate_1) {
        record = FactoryGirl.build :local_government_area_record,
          :dp_lot_number => "1",
          :dp_plan_number => "DP002",
          :land_and_property_information_record => lpi_sp,
          :local_government_area => lga_error_2
        record.save!(:validate => false)
        record
      }

      let!(:lga_dp_duplicate_2) {
        record = FactoryGirl.build :local_government_area_record,
          :dp_lot_number => "1",
          :dp_plan_number => "DP002",
          :land_and_property_information_record => lpi_sp,
          :local_government_area => lga_error_2
        record.save!(:validate => false)
        record
      }

      it "should not be valid" do
        lpr = LandParcelRecord.new("1//DP002")

        lpr.valid?.should be_false
      end

      it "should add an error for the duplicate dp" do
        lpr = LandParcelRecord.new("1//DP002")

        lpr.valid?

        lpr.errors.keys.should include :duplicate_dp
      end

      it "should include the number of duplicates in the error" do
        lpr = LandParcelRecord.new("1//DP002")

        lpr.valid?

        lpr.errors[:duplicate_dp].should include "2"
      end
    end

    context "where land parcel only in the LGA records" do

      let!(:lga_error_sp_1) {
        FactoryGirl.build(:local_government_area_record,
          :dp_lot_number => "1",
          :dp_plan_number => "SP001",
          :land_and_property_information_record => nil,
          :local_government_area => lga_error_1).save(:validate => false)
      }

      let!(:lga_error_sp_2) {
        FactoryGirl.build(:local_government_area_record,
          :dp_lot_number => "2",
          :dp_plan_number => "SP001",
          :land_and_property_information_record => nil,
          :local_government_area => lga_error_1).save(:validate => false)
      }

      let!(:lga_error_lgar) {
        FactoryGirl.build(:local_government_area_record,
          :dp_lot_number => "1",
          :dp_plan_number => "DP999",
          :land_and_property_information_record => nil,
          :local_government_area => lga_error_1).save(:validate => false)
      }

      it "should add an error if it is a common SP property" do
        lpr = LandParcelRecord.new("//SP001")

        lpr.valid?.should be_false

        lpr.errors.keys.should include :only_in_council_sp_common_property
      end

      it "should add an error if it is a SP property" do
        lpr = LandParcelRecord.new("1//SP001")

        lpr.valid?.should be_false

        lpr.errors.keys.should include :only_in_council_sp
      end

      it "should add an error if it is a normal property" do
        lpr = LandParcelRecord.new("1//DP999")

        lpr.valid?.should be_false

        lpr.errors.keys.should include :only_in_council
      end

    end

    it "should add an error if it is only in the LPI records" do
      lpr = LandParcelRecord.new("//DP666")

      lpr.valid?.should be_false

      lpr.errors.keys.should include :only_in_lpi
    end

    context "is a SP land parcel with inconsistent attributes" do

      it "should add a general error if it is a common property" do
        lpr = LandParcelRecord.new("//SP1800")

        lpr.valid?.should be_false

        lpr.errors.keys.should include :inconsistent_attributes_sp_common
      end

      it "should add specific errors against attributes" do
        lpr = LandParcelRecord.new("1//SP1800")

        lpr.valid?.should be_false

        lpr.errors.keys.should include :inconsistent_attributes_sp
      end

    end
  end

  describe '#attribute_error_information' do
    let!(:lga_with_invalid_attribute) {
      FactoryGirl.build(:local_government_area_record,
        :dp_lot_number => "97",
        :dp_plan_number => "XF31406",
        :lep_si_zone => "B3",
        :land_area => "100",
        :frontage => "100",
        :if_heritage_item => "Heritage Item",
        :acid_sulfate_soil_class => "3").save(:validate => false)
    }

    it "should be blank if there are no errors" do
      lpr = LandParcelRecord.new("//SP123")

      lpr.errors.blank?.should be_true
    end

    it "should include errors for each of the incorrect attributes" do
      lpr = LandParcelRecord.new("97//XF31406")

      lpr.attribute_error_information.has_key?(:dp_plan_number).should be_true
    end
  end

  describe "#inconsistent_attribute_information" do
    it "should return an empty hash if there are no inconsistent attributes" do
      lpr = LandParcelRecord.new("1//DP123")

      lpr.inconsistent_attribute_information.blank?.should be_true
    end

    it "should return all of the inconsistent attributes and their values" do
      lpr = LandParcelRecord.new("1//SP1800")

      lpr.inconsistent_attribute_information.keys.should include(
        "if_mine_subsidence", "if_acid_sulfate_soil", "if_flood_control_lot")
    end
  end

  describe '#address_information' do
    let!(:lpr_record) { LandParcelRecord.new("1//DP123") }
    let!(:address_information) { lpr_record.address_information }

    it "should contain the appropriate information" do
      address_information.keys.should include(:title_reference,
        :street_address, :council)
    end

    it "should contain the title reference of the land parcel" do
      address_information[:title_reference].should eq lpr_record.title_reference
    end

    it "should contain the street address of the land parcel" do
      address_information[:street_address].should eq({
        :street => " Broughton",
        :suburb => "CAMDEN",
        :state => "NSW 2570"
      })
    end

    it "should contain the name of the council" do
      address_information[:council].should eq("Camden Council")
    end
  end

  describe '#land_information' do
    let!(:lpr_record) { LandParcelRecord.new("1//DP123") }
    let!(:land_information) { lpr_record.land_information }

    it "should contain the appropriate information" do
      land_information.keys.should include(:lep_si_zone, :area, :heritage_status,
        :acid_sulfate_soil_class)
    end

    it "should contain the zone of the land parcel" do
      land_information[:lep_si_zone].should eq "B3"
    end

    it "should contain the area of the land parcel" do
      land_information[:area].should eq "100.0"
    end

    it "should contain the frontage of the land parcel" do
      land_information[:frontage].should eq "100.0"
    end

    it "should contain the heritage status of the land parcel" do
      land_information[:heritage_status].should eq "Heritage Item"
    end

    it "should contain the acid sulfate soil class of the land parcel" do
      land_information[:acid_sulfate_soil_class].should eq "3"
    end
  end

  describe '#record_information' do
    context "record is not part of an lpi" do
      let!(:lpr_record) { LandParcelRecord.new("1//DP123") }
      let!(:record_information) { lpr_record.record_information }

      context "record is not a strata plot" do
        it "should contain the appropriate information" do
          record_information.keys.should include(:council_file_date_of_update,
            :council_id)
        end

        it "should not contain information about the lpi" do
          record_information.keys.should_not include(:cadid, :lpi_last_update)
        end
      end

      context "record is in a strata plot" do
        let!(:lpr_record) { LandParcelRecord.new("1//SP123") }
        let!(:record_information) { lpr_record.record_information }

        it "should contain the appropriate information" do
          record_information.keys.should include(:council_file_date_of_update,
            :council_id, :lots_in_strata_plan)
        end
      end
    end
  end

  pending '#production_information'

  describe "clean_information" do
    it "removes blank values from key value pairs" do
      lpr = LandParcelRecord.new("1//DP123")
      lpr.send(:clean_information, {
        :a => nil,
        :b => :c,
        :d => nil
      }).should eq({ :b => :c })
    end
  end

  describe "clean_information_unless" do
    it "removes blank values from key value pairs" do
      lpr = LandParcelRecord.new("1//DP123")
      lpr.send(:clean_information_unless, {
        :a => nil,
        :b => :c,
        :d => nil
      }, nil).should eq({
        :a => nil,
        :d => nil
      })
    end
  end

  describe "#search_by_address" do

    let!(:lga_with_fake_address_1) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "1",
        :dp_plan_number => "DP456",
        :lep_si_zone => "B1",
        :land_area => "100",
        :frontage => "100",
        :if_heritage_item => "Heritage Item",
        :ad_unit_no => "1",
        :ad_st_no_from => "2",
        :ad_st_no_to => "3",
        :ad_st_name => "Fake",
        :ad_st_type => "Street",
        :ad_st_type_suffix => "",
        :ad_postcode => "456",
        :ad_suburb => "FAKEVILLE",
        :ad_lga_name => "FAKEINGTON"
    }

    let!(:lga_with_fake_address_2) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "2",
        :dp_plan_number => "DP456",
        :lep_si_zone => "B2",
        :land_area => "100",
        :frontage => "100",
        :if_heritage_item => "Heritage Item",
        :ad_unit_no => "2",
        :ad_st_no_from => "2",
        :ad_st_no_to => "3",
        :ad_st_name => "Fake",
        :ad_st_type => "Street",
        :ad_st_type_suffix => "",
        :ad_postcode => "456",
        :ad_suburb => "FAKEVILLE",
        :ad_lga_name => "FAKEINGTON"
    }

    let!(:lga_with_fake_address_3) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "3",
        :dp_plan_number => "DP456",
        :lep_si_zone => "B3",
        :land_area => "100",
        :frontage => "100",
        :if_heritage_item => "Heritage Item",
        :ad_unit_no => "1",
        :ad_st_no_from => "4",
        :ad_st_no_to => "5",
        :ad_st_name => "Fake",
        :ad_st_type => "Street",
        :ad_st_type_suffix => "",
        :ad_postcode => "456",
        :ad_suburb => "FAKEVILLE",
        :ad_lga_name => "FAKEINGTON"
    }

    context "without pagination" do
      it "returns all of the land parcel where the address is matched" do
        result = LandParcelRecord.search_by_address "Fake Street"
        result.length.should eq 3
      end

      it "returns all of the land parcel where the address is matched" do
        result = LandParcelRecord.search_by_address "2-3 Fake Street"
        result.length.should eq 2
      end

      it "returns all of the land parcel where the address is matched" do
        result = LandParcelRecord.search_by_address "1/2-3 Fake Street"
        result.length.should eq 1
      end
    end

    context "with pagination" do
      it "returns all of the land parcel where the address is matched" do
        result = LandParcelRecord.search_by_address "Fake Street",
          :paginate => {
            :per_page => 1
          }
        result[:land_parcels].length.should eq 1
        result[:land_parcels].should include(lga_with_fake_address_1)
        result[:pagination].should eq({
         :current_page => 1,
         :next_page => 2,
         :per_page => 1,
         :previous_page => nil,
         :total_entries => 3,
         :total_pages => 3
        })
      end
    end

  end

end
