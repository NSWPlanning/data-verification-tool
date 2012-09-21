require 'spec_helper'

describe "Local Goverment Area" do

  include LibSpecHelpers

  let(:admin_user)  { FactoryGirl.create :admin_user }

  describe "create an LGA" do

    specify do

      sign_in_as admin_user

      click_on 'Councils'
      click_on 'Create new local government area'

      fill_in 'Name', :with => 'New LGA name'
      fill_in 'Alias', :with => 'NEW LGA NAME'
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
      page.should have_content('Data Quality Targets')
      page.should have_content('Detailed Reports')
      page.should have_content('Upload new data file')
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
      page.should have_content('Invalid Records')
      page.should have_content('More Information')

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
      local_government_area_details_for(local_government_area).click_on 'Edit'

      fill_in 'Name', :with => 'New Name'
      click_on 'Update LGA'

      header.should have_content('New Name')
    end
  end

  describe 'managing members' do

    let!(:lga)        { FactoryGirl.create :local_government_area }
    let!(:other_lga)  { FactoryGirl.create :local_government_area }
    let!(:other_user) { FactoryGirl.create :user }

    specify do
      sign_in_as admin_user

      click_on 'Councils'

      click_on lga.name
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

      click_on 'Invalid record details'

      header.should have_content('Error records for Camden')

      # Invalid title reference
      invalid_title_reference_list.should have_content('XF31406')

      # Duplicate DP
      duplicate_dp_list.should have_content('1//DP935306')

      # Invalid Address
      invalid_address_list.should have_content('10//DP413119')
      invalid_address_list.should have_content('7//DP37598')
      invalid_address_list.should have_content('A//DP155195')

      # Missing SI zone - No records in the test data
      missing_si_zone_list.should have_content('No errors')

      # Inconsistent Attributes
      inconsistent_attributes_list.should have_content('SP85521')
      inconsistent_attributes_list.should have_content('if_mine_subsidence')

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

end
