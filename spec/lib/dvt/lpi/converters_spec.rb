require 'lib_spec_helper'

describe DVT::LPI::Converters do

  describe DVT::LPI::Converters::CADID do

    subject { DVT::LPI::Converters::CADID }

    let(:field)                 { "12345" }
    let(:field_info)            { mock('field_info', :header => 'CADID') }
    let(:unmatched_field_info)  { mock('unmatched_field_info', :header => 'FOO') }

    it "parses field to an integer" do
      subject.call(field, field_info).should == field.to_i
    end

    it "raises an exception if the field cannot be parsed" do
      lambda do
        subject.call("abc", field_info)
      end.should raise_exception(ArgumentError)
    end

    it "returns non CADID fields unmodified" do
      subject.call(field, unmatched_field_info).should == field
    end

  end

end
