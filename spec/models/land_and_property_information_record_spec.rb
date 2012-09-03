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

end
