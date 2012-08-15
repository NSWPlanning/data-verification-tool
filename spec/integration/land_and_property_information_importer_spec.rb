require 'spec_helper'

describe LandAndPropertyInformationImporter do

  include LpiSpecHelpers

  let(:user)      { FactoryGirl.create(:admin_user) }
  let(:filename)  { fixture_filename('lpi/EHC_LPMA_19710630.csv') }
  let!(:sutherland_shire_lga)      {
    FactoryGirl.create(
      :local_government_area, :name => 'Sutherland Shire',
      :alias => 'SUTHERLAND SHIRE'
    )
  }
  let!(:bogan_shire_lga)      {
    FactoryGirl.create(
      :local_government_area, :name => 'Bogan Shire',
      :alias => 'BOGAN SHIRE'
    )
  }


  subject { described_class.new(filename, user) }

  describe '.import' do

    it 'imports the LPI records' do

      lambda do
        subject.import
      end.should change(LandAndPropertyInformationRecord, :count).by(1)

      subject.processed.should == 1
      subject.created.should == 1
      subject.updated.should == 0
      subject.error_count.should == 0

    end

    context 'when file has already been imported' do

      before do
        described_class.new(filename, user).import
      end

      it 'does nothing' do

        lambda do
          subject.import
        end.should_not change(LandAndPropertyInformationRecord, :count)

        subject.processed.should == 1
        subject.created.should == 0
        subject.updated.should == 0
        subject.error_count.should == 0

      end

    end

    context 'imports with duplicate records' do

      let(:filename)  { fixture_filename('lpi/EHC_LPMA_19710701.csv') }

      it 'skips the duplicate and registers the error' do

        lambda do
          subject.import
        end.should change(LandAndPropertyInformationRecord, :count).by(2)

        subject.processed.should == 3
        subject.created.should == 2
        subject.updated.should == 0
        subject.error_count.should == 1

        subject.exceptions.length.should == 1
      end

    end

    context 'imports with an unknown LGA name' do

      let(:filename)  { fixture_filename('lpi/EHC_LPMA_19710702.csv') }

      it 'skips the unknown LGA and registers the error' do

        lambda do
          subject.import
        end.should change(LandAndPropertyInformationRecord, :count).by(1)

        subject.processed.should == 2
        subject.created.should == 1
        subject.updated.should == 0
        subject.error_count.should == 1

        subject.exceptions.length.should == 1
      end

    end

    it 'removes unreferenced LPIs from the database'

  end
end
