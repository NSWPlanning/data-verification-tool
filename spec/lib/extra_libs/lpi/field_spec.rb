require 'lpi_spec_helper'

describe LPI::Field do

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
end
