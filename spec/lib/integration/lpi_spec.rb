require 'lib_spec_helper'

describe DVT::LPI::DataFile do

  include LibSpecHelpers

  specify do
    lpi_data_file = described_class.new(
      fixture_filename('lpi/EHC_LPMA_19710630.csv')
    )

    lpi_data_file.date.should == Date.parse('30 Jun 1971')

    record = lpi_data_file.first

    record.cadid.should == 101243902
    record.cadastre_id.should == record.cadid

    record.lotnumber.should == '12'
    record.lot_number.should == record.lotnumber

    record.sectionnumber.should == ''
    record.section_number.should == record.sectionnumber

    record.planlabel.should == 'DP260721'
    record.plan_label.should == record.planlabel

    record.std_dp_lot_id.should == '12//DP260721'
    record.title_reference.should == record.std_dp_lot_id

    record.startdate.should == '26-NOV-2004 19:43:50'
    record.start_date.should == record.startdate

    record.enddate.should == '01-JAN-3000 0:00:00'
    record.end_date.should == record.enddate

    record.modifieddate.should == '24-JUN-1992 00:00:00'
    record.modified_date.should == record.modifieddate

    record.lastupdate.should == '26-NOV-2004 19:43:50'
    record.last_update.should == record.lastupdate

    record.lganame.should == 'SUTHERLAND SHIRE'
    record.lga_name.should == record.lganame

    record.md5sum.should == '4f8eb6a34f9a86482122c671776ce16d'
    record.should be_valid
  end

end
