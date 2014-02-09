require 'spec_helper'

describe LocalGovernmentAreaRecordImportLogsController do
  describe '#show' do

    let(:lga_record_import_log) {
      double(
        'lga_record_import_log', :id => 123,
        :statistics_sets => statistics_sets,
        :finished_at => Time.now
      )
    }
    let(:lga) {
      double('lga', :id => 456, :name => 'Dummy LGA', :most_recent_import_date => Time.now, :most_recent => :lga_record_import_log)
    }
    let(:local_government_areas)  { double('local_government_areas') }
    let(:statistics_sets)         { double('council_file_statistics') }

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
      assigns[:statistics_sets].should == statistics_sets
      assigns[:title].should == lga.name
    end
  end
end
