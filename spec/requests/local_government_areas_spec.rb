require 'spec_helper'

describe "Local Goverment Area" do

  include LibSpecHelpers

  let(:admin_user)  { FactoryGirl.create :admin_user }

  describe "create an LGA" do

    specify do

      sign_in_as admin_user

      click_on 'Admin'
      click_on 'Create Council'

      fill_in 'Name', :with => 'New LGA name'
      fill_in 'Lpi alias', :with => 'NEW LGA NAME'
      click_on 'Create LGA'

      page.should have_content('New LGA name')

    end
  end

  describe "show the LGA list" do

    let!(:local_government_area1) {
      FactoryGirl.create :local_government_area
    }
    let!(:local_government_area2) {
      FactoryGirl.create :local_government_area
    }

    specify do
      sign_in_as admin_user

      click_on 'Councils'

      page.should have_content(local_government_area1.to_s)
      page.should have_content(local_government_area2.to_s)
    end

  end

  describe "showing an individual LGA" do

    let!(:local_government_area)  { FactoryGirl.create :local_government_area }
    let!(:local_government_area2) {
      FactoryGirl.create :local_government_area
    }

    specify do
      sign_in_as admin_user

      click_on 'Councils'
      click_on local_government_area.name

      header.should have_content(local_government_area.name)
      page.should_not have_content('Data Summary')  # no imports => not here
      page.should_not have_content('Detailed Reports') # no imports => not here
      page.should have_content('No Data Imported')
      page.should have_content('Upload data')
    end

  end

  describe 'show detailed report' do
    let!(:local_government_area)  {
      FactoryGirl.create :local_government_area, :name => 'Camden'
    }
    let!(:local_government_area2) {
      FactoryGirl.create :local_government_area
    }

    before do
      LocalGovernmentAreaRecordImporter.new(
        Rails.root.join('spec','fixtures','test-data','ehc_camden_20120820.csv'),
        admin_user
      ).tap do |importer|
        importer.local_government_area = local_government_area
      end.import
    end

    specify do
      sign_in_as admin_user

      click_on 'Councils'
      click_on local_government_area.name

      # Click on the link to the first report in the list
      detailed_reports.all('a')[0].click

      page.should have_content('Council File Statistics')
      page.should have_content('Land Parcel Statistics')
      page.should have_content('LPI Comparison')
      page.should have_content('Invalid Land Parcels')
      page.should have_content('Import Information')

    end
  end

  describe "editing an LGA" do

    let!(:local_government_area)  {
      FactoryGirl.create :local_government_area, :name => 'Old Name'
    }
    let!(:other_local_government_area)  {
      FactoryGirl.create :local_government_area
    }

    specify do
      sign_in_as admin_user

      click_on 'Councils'
      local_government_area_details_for(local_government_area).click_on local_government_area.name
      click_on 'Admin'
      click_on 'Edit Council'

      fill_in 'Name', :with => 'New Name'
      click_on 'Update LGA'

      header.should have_content('New Name')
    end
  end

  describe 'uploading an LGA file' do

    let!(:lga)  { FactoryGirl.create :local_government_area, :name => 'Foo' }
    let!(:user) { FactoryGirl.create :user, :local_government_areas => [lga] }

    specify do

      sign_in_as user

      expect do
        attach_file('data_file', fixture_filename('lga/EHC_FOO_20120822.csv'))
        click_on 'Upload'

        page.should have_content('Your data file will be processed shortly')
      end.to change(QC, :count).by(1)

      # Create a class to access the queue_classic job queue easily
      class QueueClassicJobs < ActiveRecord::Base
        def args
          JSON.parse(read_attribute(:args))
        end
      end

      job = QueueClassicJobs.first
      job.q_name.should == 'default'
      job.method.should == 'LocalGovernmentAreaRecordImporter.import'
      # Jobs args should be [lga.id, file_path, user.id]
      job.args[0].should == lga.id
      job.args[1].should match /EHC_FOO_20120822\.csv$/
      job.args[2].should == user.id

    end

  end

=begin
  The current managing members UI is split across both LGA display and edit
  screens. It needs to all be brought into the LGA edit/settings screen.

  describe 'managing members' do

    let!(:lga)        { FactoryGirl.create :local_government_area }
    let!(:other_lga)  { FactoryGirl.create :local_government_area }
    let!(:other_user) { FactoryGirl.create :user }

    specify do
      sign_in_as admin_user

      click_on 'Councils'

      within(:css, "div[data-name=\"#{lga.name}\"]") { click_on "Edit" }

      member_list.should_not have_content(
        other_user.email
      )
      member_list.click_on 'Edit'
      select other_user.email, :from => 'Members'
      click_on 'Update'

      member_list.should have_content(
        other_user.email
      )

      header.should have_content(lga.name)
    end
  end
=end


  describe 'error records page' do

    let!(:lga)  { FactoryGirl.create :local_government_area, :name => 'Camden' }
    let!(:user) { FactoryGirl.create :user, :local_government_areas => [lga] }

    before do
      LocalGovernmentAreaRecordImporter.new(
        Rails.root.join('spec','fixtures','test-data','ehc_camden_20120820.csv'),
        admin_user
      ).tap do |importer|
        importer.local_government_area = lga
      end.import
    end

    specify do

      sign_in_as user

      click_link 'invalid-records'

      # Invalid title reference
      invalid_title_reference_list.should have_content('XF31406')

      # Duplicate DP
      duplicate_dp_list.should have_content('1//DP935306')

      # Invalid Address
      invalid_address_list.should have_content('10//DP413119')
      invalid_address_list.should have_content('7//DP37598')
      invalid_address_list.should have_content('A//DP155195')

      # Missing SI zone
      missing_si_zone_list.should have_content('2//DP34231')

      # Inconsistent Attributes
      inconsistent_attributes_list.should have_content('SP85521')
      inconsistent_attributes_list.should have_content('if_mine_subsidence')

    end

  end

  describe 'only in council page' do

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

    specify 'as html' do

      sign_in_as user

      click_link 'only-in-council'

      # DP
      dp_list.should have_content('16//DP236805')
      dp_list.should have_content('100003')
      dp_list.should have_content('1//DP196232')
      dp_list.should have_content('100020')
      dp_list.should_not have_content('3//DP942533')

      # SP
      sp_list.should have_content('31//SP83421')
      sp_list.should have_content('100100')
      sp_list.should_not have_content('5//SP85521')

    end

  end

  describe 'only in lpi page' do

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

    specify do

      sign_in_as user

      click_link 'only-in-lpi'

      # DP
      dp_list.should have_content('1//DP590490')
      dp_list.should have_content('100000021')
      dp_list.should_not have_content('3//DP942533')

      # SP
      sp_list.should have_content('//SP5432')
      sp_list.should have_content('100000066')
      sp_list.should_not have_content('5//SP85521')

    end

  end


  def local_government_area_details_for(local_government_area)
    find("#local_government_area_#{local_government_area.id}")
  end

  def member_list
    find('#member_list')
  end

  def detailed_reports
    find('#detailed_reports')
  end

  def invalid_title_reference_list
    find('#invalid_title_referenceTab')
  end

  def duplicate_dp_list
    find('#duplicate_dpTab')
  end

  def invalid_address_list
    find('#invalid_addressTab')
  end

  def missing_si_zone_list
    find('#missing_si_zoneTab')
  end

  def inconsistent_attributes_list
    find('#inconsistent_attributesTab')
  end

  def dp_list
    find_by_id('dpTab')
  end

  def sp_list
    find_by_id('spTab')
  end
end
