require 'lpi_spec_helper'

describe LPI::DataFile do

  include LpiSpecHelpers

  specify do
    lpi_data_file = LPI::DataFile.new(fixture_filename('lpi/lpi_sample.csv'))

    record = lpi_data_file.first
    record.cadid.should == "101243902"
  end

end
