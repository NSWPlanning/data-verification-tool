require 'lpi_spec_helper'

describe LPI::DataFile do

  include LpiSpecHelpers

  specify do
    lpi_data_file = LPI::DataFile.new(fixture_filename('lpi/lpi_sample.csv'))

    record = lpi_data_file.first
    record.cadid.should == 101243902
    record.md5sum.should == '4f8eb6a34f9a86482122c671776ce16d'
    record.startdate.should     == DateTime.parse('2004-11-26 19:43:50')
    record.enddate.should       == DateTime.parse('3000-01-01 00:00:00')
    record.modifieddate.should  == DateTime.parse('1992-06-24 00:00:00')
    record.lastupdate.should    == DateTime.parse('2004-11-26 19:43:50')
    record.should be_valid
  end

end
