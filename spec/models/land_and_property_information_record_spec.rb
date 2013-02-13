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

  describe '#common_property?' do

    it "returns true if it starts with SP" do
      subject.title_reference = "//SP9873"
      subject.common_property?.should be_true
    end

    it "returns false if it starts with DP" do
      subject.title_reference = "//DP9873"
      subject.common_property?.should_not be_true
    end

  end

end
