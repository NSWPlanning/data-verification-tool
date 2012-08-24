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
    lga_importer.error_count.should == 17
  end

end
