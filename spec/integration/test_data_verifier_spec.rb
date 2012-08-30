require 'spec_helper'

describe 'test data verification' do

  include LibSpecHelpers

  let(:user)          { FactoryGirl.create(:admin_user) }
  let(:lpi_filename)  { fixture_filename('test-data/EHC_LPMA_20120821.csv') }
  let(:lga_filename)  { fixture_filename('test-data/ehc_camden_20120820.csv') }

  let!(:camden)        {
    FactoryGirl.create(
      :local_government_area, :name => 'Camden', :alias => 'CAMDEN'
    )
  }
  let!(:tweed)        {
    FactoryGirl.create(
      :local_government_area, :name => 'Tweed', :alias => 'TWEED'
    )
  }

  let(:lpi_importer)  {
    LandAndPropertyInformationImporter.new(lpi_filename, user)
  }
  let(:lga_importer)  {
    LocalGovernmentAreaRecordImporter.new(lga_filename, user).tap do |importer|
      importer.local_government_area = camden
    end
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

  it 'maps the lpi records to the correct lga' do
    lpi_importer.import
    lpi_importer.error_count.should == 0

    camden.land_and_property_information_records.count.should == 12
    tweed.land_and_property_information_records.count.should == 1
  end

  it 'maps the lga records to the correct lpi record' do
    lpi_importer.import
    lga_importer.import

    # Map of Cadid to Council ID from test data
    {
      '100000001' => '100001',
      '100000002' => '100002',
      '100000018' => '100018',
      '100000018' => '100019',
      '100000010' => '100010',
      '100000017' => '100017',
    }.each do |cadid, council_id|
      lpi_record = LandAndPropertyInformationRecord.find_by_cadastre_id(cadid)
      lga_record = LocalGovernmentAreaRecord.find_by_council_id(council_id)
      lga_record.land_and_property_information_record.should == lpi_record
    end
  end

  it 'maps the lga records to the correct lga' do
    lpi_importer.import
    lga_importer.import

    LocalGovernmentAreaRecord.all.each do |lga_record|
      lga_record.local_government_area.should == camden
    end
  end

end
