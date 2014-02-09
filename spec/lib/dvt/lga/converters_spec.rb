require 'lib_spec_helper'

describe DVT::LPI::Converters do

  describe DVT::LGA::Converters::WHITESPACE_STRIP do

    subject { DVT::LGA::Converters::WHITESPACE_STRIP }

    let(:field) { '  foo  ' }
    let(:field_info)  { double('field_info') }

    it 'strips trailing and leading whitespace from fields' do
      subject.call(field, field_info).should == 'foo'
    end

    it 'leaves non string fields unmodified' do
      subject.call(42, field_info).should == 42
    end
  end
end
