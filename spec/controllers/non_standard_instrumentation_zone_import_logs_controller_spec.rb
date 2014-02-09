require 'spec_helper'

describe NonStandardInstrumentationZoneImportLogsController do
  describe '#show' do

    let(:nsi_record_import_log) {
      double('nsi_record_import_log', :id => 123, :finished_at => Time.now)
    }

    let(:lga) {
      double('lga', :id => 456, :name => 'Dummy LGA',
        :most_recent_import_date => Time.now,
        :most_recent => :nsi_record_import_log)
    }
    let(:local_government_areas) { double('local_government_areas') }
    let(:admin) { FactoryGirl.create(:admin_user) }

    before do
      login_user admin
      LocalGovernmentArea.stub(:find).with(lga.id.to_s) { lga }
      lga.stub_chain(:non_standard_instrumentation_zone_import_logs, :find).with(
        nsi_record_import_log.id.to_s
      ) { nsi_record_import_log }
    end

    specify do
      get :show, :id => nsi_record_import_log.id,
        :local_government_area_id => lga.id
      assigns[:local_government_area].should == lga
      assigns[:non_standard_instrumentation_zone_import_log].should == nsi_record_import_log
      assigns[:title].should == lga.name
    end
  end
end
