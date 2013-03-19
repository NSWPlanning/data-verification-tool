require 'lib_spec_helper'

describe DVT::NSI::DataFile do

  let(:filename)  { '/foo/ehc_lganame_lep_19710630.csv' }

  subject { described_class.new(filename, 'Camden') }

  its(:filename)  { should == filename }

  describe '#initialize' do
    %w[
      foo_lpma_19710630.csv ehc_foo_19710630.foo ehc_lpma_abc123.csv ehc_foo_bar.csv
    ].each do |filename|

      specify "#{filename} should not be valid" do
        lambda do
          described_class.new(filename, 'Camden')
        end.should raise_exception(ArgumentError)
      end

    end

    %w[
      ehc_foo_lep_19710630.csv EHC_FOO_lep_19710630.csv ehc_foo_bar_lep_20130221.csv
    ].each do |filename|

      specify "#{filename} should be valid" do
        lambda do
          described_class.new(filename, 'Camden')
        end.should_not raise_exception(ArgumentError)
      end

    end
  end

  describe '#lga_name' do
    its(:lga_name)  { should == 'lganame' }
  end

  it_should_behave_like 'a data file for', DVT::NSI
end
