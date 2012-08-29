require 'spec_helper'

describe 'test data verification' do

  include LibSpecHelpers

  let(:user)          { FactoryGirl.create(:admin_user) }
  let(:lpi_filename)  { fixture_filename('test-data/EHC_LPMA_20120821.csv') }
  let(:lga_filename)  { fixture_filename('test-data/ehc_camden_20120820.csv') }
  let(:lga)           { FactoryGirl.create(:local_government_area) }

  let(:lpi_importer)  {
    LandAndPropertyInformationImporter.new(lpi_filename, user)
  }
  let(:lga_importer)  {
    LocalGovernmentAreaRecordImporter.new(lga_filename, user)
  }

  it 'fails the specified validations correctly' do
    lpi_importer.import
    lga_importer.import

    lga_importer.should_not have_exception_on_line 2
    lga_importer.should_not have_exception_on_line 3
    lga_importer.should_not have_exception_on_line 4
    lga_importer.should_not have_exception_on_line 5

    # TODO LPI lookup scoped to LGA
    #lga_importer.should have_exception_on_line 6
    #lga_importer.should have_exception_on_line 7

    # Invalid DP number
    lga_importer.should have_exception_on_line 8
    lga_importer.should have_exception_on_line 9

    # TODO Duplicate DP number
    #lga_importer.should have_exception_on_line 10
    #lga_importer.should have_exception_on_line 11

    # Missing postcode
    lga_importer.should have_exception_on_line 12

    # Missing suburb
    lga_importer.should have_exception_on_line 13

    # From street number is zero
    lga_importer.should have_exception_on_line 14

    lga_importer.should_not have_exception_on_line 15
    lga_importer.should_not have_exception_on_line 16

    # TODO inconsistent SP records
    # lga_importer.should have_exception_on_line 17
    # lga_importer.should have_exception_on_line 18
    # lga_importer.should have_exception_on_line 19

    # Council ID is missing
    lga_importer.should have_exception_on_line 20

    # Attributes blank
    lga_importer.should have_exception_on_line 21

    # TODO Only in LPI

    pending "lga_importer.error_count.should == 17"
  end

end
