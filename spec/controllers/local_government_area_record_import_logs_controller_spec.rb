require 'spec_helper'

describe LocalGovernmentAreaRecordImportLogsController do
  describe '#show' do

    let(:lga_record_import_log) { mock('lga_record_import_log', :id => 123) }
    let(:lga) {
      mock('lga', :id => 456, :name => 'Dummy LGA')
    }
    let(:local_government_areas)  { mock('local_government_areas') }

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
      assigns[:title].should == lga.name
    end
  end
end
