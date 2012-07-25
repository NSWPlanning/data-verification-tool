require 'spec_helper'

describe User do

  describe '#to_s' do

    before do
      subject.email = 'foo@example.com'
    end

    its(:to_s)  { should == 'foo@example.com' }

  end

end
