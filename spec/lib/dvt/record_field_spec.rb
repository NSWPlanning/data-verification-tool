require 'lib_spec_helper'

describe DVT::RecordField do

  let(:name)    { 'FIELD_NAME' }

  subject { described_class.new(name) }

  its(:name)    { should == name }

  describe '#aliases' do

    it "defaults to an empty array" do
      subject.aliases.should == []
    end

    it "can be overridden on initialize" do
      obj = described_class.new('FOO', :aliases => ['foo', 'bar'])
      obj.aliases.should == ['foo', 'bar']
    end

  end

  describe '#to_attribute' do

    its(:to_attribute) { should == name.downcase }

    context 'when field has aliases' do

      subject { described_class.new('FOO', :aliases => [:bar, :baz]) }

      its(:to_attribute)  { should == 'bar' }
    end

  end

  describe '#required' do

    it "defaults to true" do
      subject.required.should == true
    end

    it "can be set to false on initialize" do
      obj = described_class.new('FOO', :required => false)
      obj.required.should == false
    end
  end
end
