require 'lib_spec_helper'

describe DVT::LPI::DataFile do

  let(:filename)  { '/foo/EHC_LPMA_19710630.csv' }

  subject { described_class.new(filename) }

  its(:filename)  { should == filename }

  describe '#initialize' do
    %w[
      FOO_LPMA_19710630.csv EHC_FOO_19710630.csv EHC_FOO_19710630.foo
      EHC_LPMA_abc123.csv
    ].each do |filename|

      specify "#{filename} should not be valid" do
        lambda do
          described_class.new(filename)
        end.should raise_exception(ArgumentError)
      end

    end
  end

  it_should_behave_like 'a data file for', DVT::LPI

end
