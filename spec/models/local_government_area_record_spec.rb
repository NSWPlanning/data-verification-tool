require 'spec_helper'

describe LocalGovernmentAreaRecord do

  describe '#has_invalid_title_reference?' do

    before do
      subject.dp_plan_number = dp_plan_number
      subject.dp_lot_number = dp_lot_number
    end

    context 'when title reference is valid' do
      let(:dp_plan_number) { 'DP123' }
      let(:dp_lot_number) { '4' }
      it { should_not have_invalid_title_reference }
    end

    context 'when plan number is invalid' do
      let(:dp_plan_number) { 'XP123' }
      let(:dp_lot_number) { '4' }
      it { should have_invalid_title_reference }
    end

    context 'when lot number is empty and plan number is dp' do
      let(:dp_plan_number) { 'DP123' }
      let(:dp_lot_number) { '' }
      it { should have_invalid_title_reference }
    end

    context 'when lot number is empty and plan number is sp' do
      let(:dp_plan_number) { 'SP123' }
      let(:dp_lot_number) { '' }
      it { should_not have_invalid_title_reference }
    end

  end

  describe '#missing_si_zone?' do

    before do
      subject.lep_si_zone = lep_si_zone
    end

    context 'when si zone is present' do
      let(:lep_si_zone) { 'R2' }
      its(:missing_si_zone?) { should == false }
    end

    context 'when si zone is missing' do
      let(:lep_si_zone) { '' }
      its(:missing_si_zone?) { should == true }
    end
  end

  describe '#is_sp_property' do
    it 'should be true if the plan number starts with SP' do
      subject.dp_plan_number = 'SP123'
      subject.is_sp_property?.should be_true
    end

    it 'should be false if the plan number does not start with SP' do
      subject.dp_plan_number = 'DP123'
      subject.is_sp_property?.should be_false
    end
  end

  context "part of a strata plot" do

    let!(:sp1) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "1",
        :dp_plan_number => "SP123",
        :if_mine_subsidence => "Yes",
        :if_acid_sulfate_soil => "Yes",
        :if_flood_control_lot => "No"
    }

    let!(:sp2) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "2",
        :dp_plan_number => "SP123",
        :if_mine_subsidence => "No",
        :if_acid_sulfate_soil => "Yes",
        :if_flood_control_lot => "Yes"
    }

    let!(:sp3) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "3",
        :dp_plan_number => "SP123",
        :if_mine_subsidence => "Yes",
        :if_acid_sulfate_soil => "No",
        :if_flood_control_lot => "Yes"
    }

    let!(:lgar) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "1",
        :dp_plan_number => "DP123"
    }

    let!(:lgar_2) {
      FactoryGirl.create :local_government_area_record,
        :dp_lot_number => "2",
        :dp_plan_number => "DP123"
    }

    describe 'sp_common_plot_neighbours' do
      it "finds all of the neighbour in the common plot" do
        sp1.sp_common_plot_neighbours.should include sp3
        sp1.sp_common_plot_neighbours.should include sp2
      end

      it "does not include itself in the set of neighbours" do
        sp1.sp_common_plot_neighbours.should_not include sp1
      end

      it "returns nothing if it is not a sp" do
        lgar.sp_common_plot_neighbours.blank?.should be_true
      end
    end

    describe 'number_of_sp_common_plot_neighbours' do
      it "counts all of the neighbour in the common plot" do
        sp1.number_of_sp_common_plot_neighbours.should eq 2
      end

      it "returns 0 if it is not a sp" do
        lgar.number_of_sp_common_plot_neighbours.should eq 0
      end
    end

    describe 'sp_attributes_that_differ_from_neighbours' do
      it "returns a diff for all of the attributes, across all neighbours" do
        diff = sp1.sp_attributes_that_differ_from_neighbours

        diff.keys.should include("if_mine_subsidence", "if_acid_sulfate_soil",
          "if_flood_control_lot")
      end

      it "returns nothing if it is not a sp" do
        lgar.sp_attributes_that_differ_from_neighbours.blank?.should be_true
      end
    end

  end

end
