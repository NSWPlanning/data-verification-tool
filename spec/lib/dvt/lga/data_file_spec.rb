require 'lib_spec_helper'

describe DVT::LGA::DataFile do

  let(:filename)  { '/foo/ehc_lganame_19710630.csv' }

  subject { described_class.new(filename) }

  its(:filename)  { should == filename }

  describe '#initialize' do
    %w[
      foo_lpma_19710630.csv ehc_foo_19710630.foo ehc_lpma_abc123.csv
    ].each do |filename|

      specify "#{filename} should not be valid" do
        lambda do
          described_class.new(filename)
        end.should raise_exception(ArgumentError)
      end

    end
  end

  it_should_behave_like 'a data file for', DVT::LGA
end
