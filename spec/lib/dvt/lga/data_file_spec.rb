require 'lib_spec_helper'

describe DVT::LGA::DataFile do

  let(:filename)  { '/foo/ehc_lganame_19710630.csv' }

  subject { described_class.new(filename) }

  its(:filename)  { should == filename }

  describe '#initialize' do
    %w[
      foo_lpma_19710630.csv ehc_foo_19710630.foo ehc_lpma_abc123.csv ehc_foo_bar.csv
    ].each do |filename|

      specify "#{filename} should not be valid" do
        lambda do
          described_class.new(filename)
        end.should raise_exception(ArgumentError)
      end

    end

    %w[ehc_foo_19710630.csv EHC_FOO_19710630.csv ehc_foo_bar_20130221.csv].each do |filename|

      specify "#{filename} should be valid" do
        lambda do
          described_class.new(filename)
        end.should_not raise_exception(ArgumentError)
      end

    end
  end

  describe '#lga_name' do
    its(:lga_name)  { should == 'lganame' }
  end

  it_should_behave_like 'a data file for', DVT::LGA
end
