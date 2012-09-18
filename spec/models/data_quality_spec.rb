require 'lib_spec_helper'
require_relative '../../app/models/import_statistics_set'
require_relative '../../app/models/data_quality'

describe DataQuality do

  let(:attributes)  {
    {
      :in_council_and_lpi => 5,
      :only_in_lpi        => 3,
      :only_in_council    => 2
    }
  }

  subject { described_class.new(attributes) }

  it_should_behave_like 'an import statistics set'

  its(:in_council_and_lpi_percentage) { should == 50.0 }
  its(:only_in_lpi_percentage)        { should == 30.0 }
  its(:only_in_council_percentage)    { should == 20.0 }

end
