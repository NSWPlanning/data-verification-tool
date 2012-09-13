require 'lib_spec_helper'
require_relative '../../app/models/import_statistics_set'
require_relative '../../app/models/data_quality'

RSpec::Matchers.define :have_percentage_method_for do |collection|
  match do |actual|
    count_method = "#{collection}_count"
    percentage_method = "#{collection}_percentage" 
    actual.stub(count_method => 50, :lpi_count => 100)
    actual.send(percentage_method) == 50.0
  end
end

describe DataQuality do

  let(:attributes)  {
    {
      :in_council_and_lpi => 50,
      :only_in_lpi        => 25,
      :only_in_council    => 75,
      :total              => 100
    }
  }

  subject { described_class.new(attributes) }

  it_should_behave_like 'an import statistics set'

  its(:in_council_and_lpi_percentage) { should == 50.0 }
  its(:only_in_lpi_percentage)        { should == 25.0 }
  its(:only_in_council_percentage)    { should == 75.0 }

end
