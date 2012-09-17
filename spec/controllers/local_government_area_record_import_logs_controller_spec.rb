require 'spec_helper'

describe LocalGovernmentAreaRecordImportLogsController do
  describe '#show' do

    let(:lga_record_import_log) {
      mock(
        'lga_record_import_log', :id => 123,
        :council_file_statistics => council_file_statistics,
        :invalid_records => invalid_records,
        :land_parcel_statistics => land_parcel_statistics
      )
    }
    let(:lga) {
      mock('lga', :id => 456, :name => 'Dummy LGA')
    }
    let(:local_government_areas)  { mock('local_government_areas') }
    let(:council_file_statistics) { mock('council_file_statistics') }
    let(:invalid_records)         { mock('invalid_records') }
    let(:land_parcel_statistics)  { mock('land_parcel_statistics') }

    let(:admin) { FactoryGirl.create(:admin_user) }

    before do
      login_user admin
      LocalGovernmentArea.stub(:find).with(lga.id.to_s) { lga }
      lga.stub_chain(:local_government_area_record_import_logs, :find).with(
        lga_record_import_log.id.to_s
      ) { lga_record_import_log }
    end

    specify do
      get :show, :id => lga_record_import_log.id,
        :local_government_area_id => lga.id
      assigns[:local_government_area].should == lga
      assigns[:local_government_area_record_import_log].should == lga_record_import_log
      assigns[:council_file_statistics].should == council_file_statistics
      assigns[:invalid_records].should == invalid_records
      assigns[:land_parcel_statistics].should == land_parcel_statistics
      assigns[:title].should == lga.name
    end
  end
end
