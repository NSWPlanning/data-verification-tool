require 'lib_spec_helper'
require_relative '../../app/models/import_statistics_set'
require_relative '../../app/models/land_parcel_statistics'

describe LandParcelStatistics do

  let(:attributes)  {
    {
      :council_unique_dp => 2,
      :council_unique_parent_sp => 3,
      :lpi_unique_dp => 7,
      :lpi_unique_parent_sp => 11
    }
  }

  subject { described_class.new(attributes) }

  it_should_behave_like 'an import statistics set'

  its(:council_total) { should == 5 }
  its(:lpi_total)     { should == 18 }

end
