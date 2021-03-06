require 'spec_helper'
require 'rack/test'

describe "Local Goverment Area" do

  include LibSpecHelpers
  include Rack::Test::Methods


  let(:admin_user)  { FactoryGirl.create :admin_user }


  describe 'uploading an LGA file' do
    let!(:lga)  { FactoryGirl.create :local_government_area, :name => 'Camden' }
    let!(:user) { FactoryGirl.create :user, :local_government_areas => [lga] }

    before do
      LandAndPropertyInformationImporter.new(
        Rails.root.join('spec','fixtures','test-data','EHC_LPMA_20120821.csv'), 
        admin_user
      ).import
    end

    specify 'POST file' do  
      authorize admin_user.email, "password"

      data_file = Rack::Test::UploadedFile.new(Rails.root.join('spec','fixtures','test-data','ehc_camden_20120820.csv'), "text/csv")
      header "Accept", "application/json"
      
      post "/local_government_areas/#{lga.id.to_s}/import", data_file: data_file
      last_response.should be_ok
    end
  end


  describe 'retrieving json' do

    let!(:lga)  { FactoryGirl.create :local_government_area, :name => 'Camden' }
    let!(:user) { FactoryGirl.create :user, :local_government_areas => [lga] }

    before do
      LandAndPropertyInformationImporter.new(
        Rails.root.join('spec','fixtures','test-data','EHC_LPMA_20120821.csv'), 
        admin_user
      ).import
      LocalGovernmentAreaRecordImporter.new(
        Rails.root.join('spec','fixtures','test-data','ehc_camden_20120820.csv'),
        admin_user
      ).tap do |importer|
        importer.local_government_area = lga
      end.import
    end

    specify 'only in council' do  
      authorize user.email, "password"
      get "/local_government_areas/#{lga.id.to_s}/only_in_council.json" 
      last_response.should be_ok

      records = JSON.parse(last_response.body)

      # DP
      records["dp"].should have_content('16//DP236805')
      records["dp"].should have_content('100003')      
      records["dp"].should have_content('1//DP196232')      
      records["dp"].should have_content('100020')
      records["dp"].should_not have_content('3//DP942533')

      # SP
      records["sp"].should have_content('31//SP83421')
      records["sp"].should have_content('100100')
      records["sp"].should_not have_content('5//SP85521')
    end

    specify 'only in lpi' do  
      authorize user.email, "password"
      get "/local_government_areas/#{lga.id.to_s}/only_in_lpi.json" 
      last_response.should be_ok

      records = JSON.parse(last_response.body)

      # DP
      records["dp"].should have_content('1//DP590490')
      records["dp"].should have_content('100000021')
      records["dp"].should_not have_content('3//DP942533')

      # SP
      records["sp"].should have_content('//SP5432')
      records["sp"].should have_content('100000066')
      records["sp"].should_not have_content('5//SP85521')
    end

    specify 'error records' do
      authorize user.email, "password"
      get "/local_government_areas/#{lga.id.to_s}/error_records.json" 
      last_response.should be_ok

      records = JSON.parse(last_response.body)

      # Invalid title reference
      records["invalid_title_reference"].should have_content('XF31406')

      # Duplicate DP
      records["duplicate_dp"].should have_content('1//DP935306')

      # Invalid Address
      records["invalid_address"].should have_content('10//DP413119')
      records["invalid_address"].should have_content('7//DP37598')
      records["invalid_address"].should have_content('A//DP155195')

      # Missing SI zone
      records["missing_si_zone"].should have_content('2//DP34231')

      # Inconsistent Attributes
      records["inconsistent_attributes"].should have_content('SP85521')
      records["inconsistent_attributes"].should have_content('if_mine_subsidence')

    end
  end   
end
