require 'lpi_spec_helper'

describe LPI::Converters do

  describe LPI::Converters::CADID do

    subject { LPI::Converters::CADID }

    let(:field)                 { "12345" }
    let(:field_info)            { mock('field_info', :header => 'CADID') }
    let(:unmatched_field_info)  { mock('unmatched_field_info', :header => 'FOO') }

    it "parses field to an integer" do
      subject.call(field, field_info).should be_instance_of Fixnum
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

  describe LPI::Converters::DATETIME do

    let(:field)                 { "26-NOV-2004 19:43:50" }
    let(:header)                { 'STARTDATE' }
    let(:field_info)            { mock('field_info', :header => header) }
    let(:unmatched_field_info)  { mock('unmatched_field_info', :header => 'FOO') }

    subject { LPI::Converters::DATETIME }

    it "parses field to a time" do
      subject.call(field, field_info).should be_instance_of DateTime
      subject.call(field, field_info).should == DateTime.parse(field)
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
