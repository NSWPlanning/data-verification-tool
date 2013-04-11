require 'spec_helper'

describe LocalGovernmentAreasController do

  include LibSpecHelpers

  let(:admin) { FactoryGirl.create(:admin_user) }

  before do
    login_user admin
  end

  it_should_behave_like "a resource controller for", LocalGovernmentArea

  describe '#uploads' do

    context "lga uploads with lga id" do

      let!(:local_government_area) { mock_model(LocalGovernmentArea, :id => 42) }
      let!(:lga_data_file) {
        fixture_file_upload('/lga/EHC_FOO_20120822.csv', 'text/csv')
      }

      before do
        subject.stub(:find_model).with(local_government_area.id.to_s) {
          local_government_area
        }
        LocalGovernmentAreaRecordImporter.should_receive(:enqueue).
          with(local_government_area, lga_data_file, admin)
      end

      specify do
        post :import, :id => local_government_area.id, :data_file => lga_data_file
        assigns[:local_government_area].should == local_government_area
        response.should redirect_to(local_government_area_url(local_government_area))
      end

    end

    context "zone file uploads with lga id" do

      let!(:local_government_area) { mock_model(LocalGovernmentArea, :id => 42) }
      let!(:lep_data_file) {
        fixture_file_upload('/nsi/EHC_WINGECARRIBEE_LEP_20130311.csv', 'text/csv')
      }

      before do
        subject.stub(:find_model).with(local_government_area.id.to_s) {
          local_government_area
        }
        NonStandardInstrumentationZoneImporter.should_receive(:enqueue).with(
          local_government_area, lep_data_file, admin
        )
      end

      specify do
        post :import, :id => local_government_area.id, :data_file => lep_data_file
        assigns[:local_government_area].should == local_government_area
        response.should redirect_to(
          local_government_area_url(local_government_area)
        )
      end

    end

    context "lga uploads without lga id" do

      let!(:local_government_area) { mock_model(LocalGovernmentArea, :id => 42) }
      let!(:lga_data_file) {
        fixture_file_upload('/lga/EHC_FOO_20120822.csv', 'text/csv')
      }

      before do
        subject.stub(:find_model).with(local_government_area.id.to_s) {
          local_government_area
        }
        subject.stub(:lookup_alias).with("FOO") {
          local_government_area.id.to_s
        }
        LocalGovernmentAreaRecordImporter.should_receive(:enqueue).
          with(local_government_area, lga_data_file, admin)
      end

      specify do
        post :import, :data_file => lga_data_file
        assigns[:local_government_area].should == local_government_area
        response.should redirect_to(local_government_area_url(local_government_area))
      end

    end

    context "zone file uploads without lga id" do

      let!(:local_government_area) { mock_model(LocalGovernmentArea, :id => 42) }
      let!(:lep_data_file) {
        fixture_file_upload('/nsi/EHC_WINGECARRIBEE_LEP_20130311.csv', 'text/csv')
      }

      before do
        subject.stub(:find_model).with(local_government_area.id.to_s) {
          local_government_area
        }
        subject.stub(:lookup_alias).with("WINGECARRIBEE") {
          local_government_area.id.to_s
        }
        NonStandardInstrumentationZoneImporter.should_receive(:enqueue).with(
          local_government_area, lep_data_file, admin
        )
      end

      specify do
        post :import, :data_file => lep_data_file
        assigns[:local_government_area].should == local_government_area
        response.should redirect_to(
          local_government_area_url(local_government_area)
        )
      end

    end

    context "invalid filename lga uploads without lga id" do

      let!(:local_government_area) { mock_model(LocalGovernmentArea, :id => 42) }
      let!(:lga_data_file) {
        fixture_file_upload('/lga/EHC_FOO20120822.csv', 'text/csv') # invalid filename
      }

      before do
        subject.stub(:find_model).with(local_government_area.id.to_s) {
          local_government_area
        }
      end

      specify do
        post :import, :data_file => lga_data_file
        response.response_code.should == 403
      end

    end

    context "no lga exists for lga uploads without lga id" do

      let!(:local_government_area) { mock_model(LocalGovernmentArea, :id => 42) }
      let!(:lga_data_file) {
        fixture_file_upload('/lga/EHC_FOO_20120822.csv', 'text/csv') # valid filename, but LGA does not exist
      }

      specify do
        post :import, :data_file => lga_data_file
        response.response_code.should == 404
      end

    end

  end

  describe '#error_records' do

    let(:local_government_area) {
      mock_model(LocalGovernmentArea, :id => 42, :name => 'Foo', :most_recent_import_date => Time.now, :most_recent => '')
    }

    before do
      subject.stub(:find_model).with(local_government_area.id.to_s) {
        local_government_area
      }
    end

    specify do
      get :error_records, :id => local_government_area.id
      assigns[:local_government_area].should == local_government_area
      assigns[:title].should == 'Error records for Foo'
    end
  end

end
