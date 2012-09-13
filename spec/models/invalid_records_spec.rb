require 'lib_spec_helper'
require_relative '../../app/models/import_statistics_set'
require_relative '../../app/models/invalid_records'

describe InvalidRecords do

  let(:attributes)  {
    {
      :malformed => 1,
      :invalid_title_reference => 2,
      :duplicate_title_reference => 3,
      :invalid_address => 4,
      :missing_si_zone => 5,
      :inconsistent_attributes => 6,
      :total => 21
    }
  }

  subject { described_class.new(attributes) }

  it_should_behave_like 'an import statistics set'

end
