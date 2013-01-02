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
      let(:dp_lot_number) { '4' }   # not used in test
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
end
