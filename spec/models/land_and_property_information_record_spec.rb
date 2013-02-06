require 'spec_helper'

describe LandAndPropertyInformationRecord do

  describe '#retire!' do

    it 'sets retired to true' do
      subject.should_receive(:save!)
      expect {
        subject.retire!
      }.to change(subject, :retired).from(false).to(true)
    end

  end

  describe "::search" do

    let!(:lpir_1) {
      FactoryGirl.create :land_and_property_information_record
    }

    let!(:lpir_2) {
      FactoryGirl.create :land_and_property_information_record,
        :plan_label => "DP666",
        :lot_number => "1",
        :section_number => "2"
    }

    let!(:lpir_3) {
      FactoryGirl.create :land_and_property_information_record,
        :plan_label => "DP666",
        :lot_number => "1",
        :section_number => "1"
    }

    let!(:lpir_4) {
      FactoryGirl.create :land_and_property_information_record,
        :plan_label => "DP666",
        :lot_number => "2",
        :section_number => "4"
    }

    context "only one item with the specified plan label" do
      it "returns nothing if no plan number is present in the string" do
        LandAndPropertyInformationRecord.search("").count.should eq LandAndPropertyInformationRecord.count
      end

      it "returns all matches for a plan label" do
        label = lpir_1.plan_label
        result = LandAndPropertyInformationRecord.search("#{label}")
        result.first.should eq lpir_1
      end

      it "accepts additional search arguments" do
        result = LandAndPropertyInformationRecord.search("", :lga_name => "BOGAN SHIRE")
        result.count.should eq 4
      end
    end

    context "multiple items with the specified plan label" do
      it "returns all of the matches for a specified plan label" do
        label = lpir_2.plan_label
        query = "#{label}"
        result = LandAndPropertyInformationRecord.search(query)
        result.count.should eq 3
      end

      it "narrows the search down for lot number" do
        label = lpir_2.plan_label
        lot_number = lpir_2.lot_number
        query = "#{lot_number}//#{label}"
        result = LandAndPropertyInformationRecord.search(query)
        result.count.should eq 2
      end

      it "narrows the search down for lot number and section number" do
        label = lpir_2.plan_label
        lot_number = lpir_2.lot_number
        section_number = lpir_2.section_number
        query = "#{lot_number}/#{section_number}/#{label}"
        result = LandAndPropertyInformationRecord.search(query)
        result.count.should eq 1
      end
    end

  end

end
