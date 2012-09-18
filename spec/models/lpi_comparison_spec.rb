require 'lib_spec_helper'
require_relative '../../app/models/import_statistics_set'
require_relative '../../app/models/lpi_comparison'

describe LpiComparison do

  let(:attributes)  {
    {
      :in_both_dp => 2,
      :in_both_parent_sp => 3,
      :only_in_council_dp => 5,
      :only_in_council_parent_sp => 7,
      :only_in_lpi_dp => 11,
      :only_in_lpi_parent_sp => 13,
      :in_retired_lpi_dp => 17,
      :in_retired_lpi_parent_sp => 19
    }
  }

  subject { described_class.new(attributes) }

  it_should_behave_like 'an import statistics set'

  its(:in_both_total)         { should == 5 }
  its(:only_in_council_total) { should == 12 }
  its(:only_in_lpi_total)     { should == 24 }
  its(:in_retired_lpi_total)  { should == 36 }
  its(:total_total)           { should == 77 }

  its(:total_dp)        { should == 35 }
  its(:total_parent_sp) { should == 42 }

  its(:in_both_total_percentage)          { should == (5.0/77.0)*100 }
  its(:only_in_council_total_percentage)  { should == (12.0/77.0)*100 }
  its(:only_in_lpi_total_percentage)      { should == (24.0/77.0)*100 }
  its(:in_retired_lpi_total_percentage)   { should == (36.0/77.0)*100 }
  its(:total_total_percentage)            { should == 100 }

end
