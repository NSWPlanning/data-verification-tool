require 'spec_helper'

describe 'test data verification' do

  include LibSpecHelpers

  let(:user)          { FactoryGirl.create(:admin_user) }
  let(:lpi_filename)  { fixture_filename('test-data/EHC_LPMA_20120821.csv') }
  let(:lga_filename)  { fixture_filename('test-data/ehc_camden_20120820.csv') }

  let!(:camden)        {
    FactoryGirl.create(
      :local_government_area, :name => 'Camden', :lpi_alias => 'CAMDEN'
    )
  }
  let!(:tweed)        {
    FactoryGirl.create(
      :local_government_area, :name => 'Tweed', :lpi_alias => 'TWEED'
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

  it 'creates the right number of records' do
    expect {
      lpi_importer.import
    }.to change(LandAndPropertyInformationRecord, :count).by(21)
    expect {
      lga_importer.import
    }.to change(LocalGovernmentAreaRecord, :count).by(31)
  end

  it 'marks the invalid status of each record correctly' do
    lpi_importer.import
    lga_importer.import

    lga_records = camden.local_government_area_records

    # Valid records
    lga_records.find_by_council_id!('100001').should be_is_valid
    lga_records.find_by_council_id!('100002').should be_is_valid
    lga_records.find_by_council_id!('100018').should be_is_valid
    lga_records.find_by_council_id!('100019').should be_is_valid
    lga_records.find_by_council_id!('100022').should be_is_valid
    lga_records.find_by_council_id!('100010').should be_is_valid
    lga_records.find_by_council_id!('100017').should be_is_valid
    lga_records.find_by_council_id!('100200').should be_is_valid

    # Invalid records
    lga_records.find_by_council_id!('100003').should_not be_is_valid
    lga_records.find_by_council_id!('100003').should_not be_is_valid
    lga_records.find_by_council_id!('100020').should_not be_is_valid
    lga_records.find_by_council_id!('100004').should_not be_is_valid
    lga_records.find_by_council_id!('100015').should_not be_is_valid
    lga_records.find_by_council_id!('100021').should_not be_is_valid
    lga_records.find_by_council_id!('100005').should_not be_is_valid
    lga_records.find_by_council_id!('100006').should_not be_is_valid
    lga_records.find_by_council_id!('100007').should_not be_is_valid
    lga_records.find_by_council_id!('100008').should_not be_is_valid
    lga_records.find_by_council_id!('100009').should_not be_is_valid
    lga_records.find_by_council_id!('100011').should_not be_is_valid
    lga_records.find_by_council_id!('100012').should_not be_is_valid
    lga_records.find_by_council_id!('100013').should_not be_is_valid
    lga_records.find_by_council_id!('100050').should_not be_is_valid
    lga_records.find_by_council_id!('100060').should_not be_is_valid

# TODO: Metadata: Setup tests with required attributes
#    lga_records.find_by_council_id!('100016').should_not be_is_valid

# TODO: Metadata. invalid will increment by 1 and valid sill decrement
#       when we re-enable the tests for required attributes.
    camden.invalid_record_count.should == 21
    camden.valid_record_count.should == 10
  end

  it 'fails the specified validations correctly' do
    lpi_importer.import
    lga_importer.import

    lga_importer.should_not have_exception_on_line 2
    lga_importer.should_not have_exception_on_line 3
    lga_importer.should_not have_exception_on_line 4
    lga_importer.should_not have_exception_on_line 5
    lga_importer.should_not have_exception_on_line 6

    # Only in council
    lga_importer.should have_exception_on_line 7
    lga_importer.should have_exception_on_line 8
    lga_importer.should have_exception_on_line 31

    # Invalid title reference (DP number)
    lga_importer.should have_exception_on_line 9
    lga_importer.should have_exception_on_line 10
    lga_importer.should have_exception_on_line 11

    # Missing postcode
    lga_importer.should have_exception_on_line 14

    # Missing suburb
    lga_importer.should have_exception_on_line 15

    # From street number is zero
    lga_importer.should have_exception_on_line 16

    # To street number is zero
    lga_importer.should have_exception_on_line 29

    lga_importer.should_not have_exception_on_line 17
    lga_importer.should_not have_exception_on_line 18

    # Council ID is missing
    lga_importer.should have_exception_on_line 22

    # Missing SI Zone
    lga_importer.should have_exception_on_line 28

    # Attributes blank
# TODO: Metadata: Set default required attributes
#    lga_importer.should have_exception_on_line 21

    lga_importer.should have(6).base_exceptions
    # Duplicate DP number
    lga_importer.base_exceptions.select do |e|
      e.instance_of?(LocalGovernmentAreaRecordImporter::DuplicateDpError)
    end.length.should == 1
    # Inconsistent SP records
    lga_importer.base_exceptions.select do |e|
      e.instance_of?(LocalGovernmentAreaRecordImporter::InconsistentSpAttributesError)
    end.length.should == 3
    lga_importer.base_exceptions.select do |e|
      e.instance_of?(LocalGovernmentAreaRecordImporter::NotInLgaError)
    end.length.should == 2
  end

  it 'maps the lpi records to the correct lga' do
    lpi_importer.import
    lpi_importer.error_count.should == 0

    camden.land_and_property_information_records.count.should == 20
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
      lpi_record = LandAndPropertyInformationRecord.find_by_cadastre_id!(cadid)
      lga_record = LocalGovernmentAreaRecord.find_by_council_id!(council_id)
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

  describe 'repeated imports' do

    before do
      lpi_importer.import
      lga_importer.import
    end

    specify do
      second_importer = LocalGovernmentAreaRecordImporter.new(
        lga_filename, user
      )
      second_importer.local_government_area = camden

      expect { second_importer.import }.not_to change(
        LocalGovernmentAreaRecord, :count
      )

      second_importer.processed.should == lga_importer.processed
# TODO: Metadata. created will increment by one when we re-enable the tests
#       for required attributes.
      second_importer.created.should == 21
      second_importer.updated.should == lga_importer.updated
      second_importer.error_count.should == lga_importer.error_count
      second_importer.deleted.should == lga_importer.deleted
    end
  end

  describe 'statistics' do

    it 'has the correct statistics' do
      lpi_importer.import
      lga_importer.import

      council_file_statistics = lga_importer.import_log.council_file_statistics
      council_file_statistics.dp_records.should == 18
      council_file_statistics.sp_records.should == 11
      council_file_statistics.malformed_records.should == 2
      council_file_statistics.total.should == 31

      land_parcel_statistics = lga_importer.import_log.land_parcel_statistics
      land_parcel_statistics.council_unique_dp.should == 17
      land_parcel_statistics.council_unique_parent_sp.should == 6
      land_parcel_statistics.council_total.should == 23

      lpi_comparison = lga_importer.import_log.lpi_comparison
      lpi_comparison.in_both_dp.should == 14
      lpi_comparison.in_both_parent_sp.should == 5
      lpi_comparison.only_in_council_dp.should == 4
      lpi_comparison.only_in_council_parent_sp.should == 1
      lpi_comparison.only_in_lpi_dp.should == 1
      lpi_comparison.only_in_lpi_parent_sp.should == 1
      lpi_comparison.in_retired_lpi_dp.should == 0
      lpi_comparison.in_retired_lpi_parent_sp.should == 0

      invalid_records = lga_importer.import_log.invalid_records
      invalid_records.invalid_title_reference.should == 3
      invalid_records.duplicate_title_reference.should == 1
      invalid_records.invalid_address.should == 4
      invalid_records.missing_si_zone.should == 1
      invalid_records.inconsistent_attributes.should == 3
# TODO: Metadata. Will increment by one when we re-enable the tests
#       for required attributes.
      invalid_records.total.should == 12
    end

  end

  describe 'error records by type' do

    it 'provides access to the error records by type' do
      lpi_importer.import
      lga_importer.import

      lga_records = camden.local_government_area_records

      # accessors used to display the error records should have
      #  same number of results as the statistics from the import
      #  for this LGA
      lga_records.invalid_count.should == 21
      lga_records.valid_count.should == 10
# TODO: validate these:
#      lga_records.in_council_and_lpi.count.should == 18
#      lga_records.only_in_council.count.should == 4

      lga_records.invalid_title_reference.count.should == 3
      lga_records.invalid_address.count.should == 4
      lga_records.missing_si_zone.count.should == 1
    end

  end

end
