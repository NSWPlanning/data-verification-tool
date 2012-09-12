require 'lib_spec_helper'
require_relative '../../app/models/data_quality'

RSpec::Matchers.define :have_count_method_for do |collection|
  match do |actual|
    count_method = "#{collection}_count"
    actual.stub(collection => mock('collection', :count => 123))
    actual.send(count_method) == 123
  end
end

RSpec::Matchers.define :have_percentage_method_for do |collection|
  match do |actual|
    count_method = "#{collection}_count"
    percentage_method = "#{collection}_percentage" 
    actual.stub(count_method => 50, :lpi_count => 100)
    actual.send(percentage_method) == 50.0
  end
end

describe DataQuality do

  let(:local_government_area) { mock('local_government_area') }

  subject { described_class.new(local_government_area) }

  its(:local_government_area) { should == local_government_area }

  it { should have_count_method_for(:in_council_and_lpi) }
  it { should have_count_method_for(:only_in_council) }
  it { should have_count_method_for(:only_in_lpi) }

  it { should have_percentage_method_for(:in_council_and_lpi) }
  it { should have_percentage_method_for(:only_in_council) }
  it { should have_percentage_method_for(:only_in_lpi) }

end
