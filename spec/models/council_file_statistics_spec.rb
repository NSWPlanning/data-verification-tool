require 'lib_spec_helper'
require_relative '../../app/models/import_statistics_set'
require_relative '../../app/models/council_file_statistics'

describe CouncilFileStatistics do

  let(:attributes)  {
    {
      :dp_records => 50,
      :sp_records => 25
    }
  }

  subject { described_class.new(attributes) }

  it_should_behave_like 'an import statistics set'

  its(:total) { should == 75 }

end
