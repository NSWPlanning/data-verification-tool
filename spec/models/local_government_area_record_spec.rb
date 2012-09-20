require 'spec_helper'

describe LocalGovernmentAreaRecord do

  describe '#has_invalid_title_reference?' do

    before do
      subject.dp_plan_number = dp_plan_number
    end

    context 'when title reference is valid' do
      let(:dp_plan_number) { 'DP123' }
      it { should_not have_invalid_title_reference }
    end

    context 'when title reference is invalid' do
      let(:dp_plan_number) { 'XP123' }
      it { should have_invalid_title_reference }
    end

  end
end
