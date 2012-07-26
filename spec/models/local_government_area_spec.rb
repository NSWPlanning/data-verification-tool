require 'spec_helper'

describe LocalGovernmentArea do

  describe '#to_s' do
    before do
      subject.name = 'LGA name'
    end
    its(:to_s)  { should == 'LGA name' }
  end

end
