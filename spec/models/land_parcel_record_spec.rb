require 'spec_helper'

describe LandParcelRecord do

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
      :title_reference => "//SP123"
  }

  let!(:lga_sp_1) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "1",
      :dp_plan_number => "SP123",
      :land_and_property_information_record => lpi_sp
  }

  let!(:lga_sp_2) {
    FactoryGirl.create :local_government_area_record,
      :dp_lot_number => "2",
      :dp_plan_number => "SP123",
      :land_and_property_information_record => lpi_sp
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

          it "does not assign all of the lga records" do
            lpr.lga_records.should be_nil
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

  pending '#has_errors?'

  pending '#error_information'

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
      address_information[:street_address].should eq(
        "Broughton 2570 CAMDEN Camden Council")
    end

    it "should contain the name of the council" do
      address_information[:council].should eq("Camden Council")
    end
  end

  describe '#land_information' do
    let!(:lpr_record) { LandParcelRecord.new("1//DP123") }
    let!(:land_information) { lpr_record.land_information }

    it "should contain the appropriate information" do
      land_information.keys.should include(:zone, :area, :heritage_status,
        :acid_sulfate_soil_class)
    end

    it "should contain the zone of the land parcel" do
      land_information[:zone].should eq "B3"
    end

    it "should contain the area of the land parcel" do
      land_information[:area].should eq "100"
    end

    it "should contain the frontage of the land parcel" do
      land_information[:frontage].should eq "100"
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

end
