require 'spec_helper'

describe LandAndPropertyInformationImporter do

  include LibSpecHelpers

  let(:user)      { FactoryGirl.create(:admin_user) }
  let(:filename)  { fixture_filename('lpi/EHC_LPMA_19710630.csv') }
  let!(:sutherland_shire_lga)      {
    FactoryGirl.create(
      :local_government_area, :name => 'Sutherland Shire',
      :lpi_alias => 'SUTHERLAND SHIRE'
    )
  }
  let!(:bogan_shire_lga)      {
    FactoryGirl.create(
      :local_government_area, :name => 'Bogan Shire',
      :lpi_alias => 'BOGAN SHIRE'
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
      subject.deleted.should == 0
      subject.error_count.should == 0

    end

    context 'when file has already been imported' do

      let(:previous_importer) {
        described_class.new(filename, user)
      }

      it 'does nothing' do

        previous_importer.import

        lambda do
          subject.import
        end.should_not change(LandAndPropertyInformationRecord, :count)

        subject.processed.should == 1
        subject.created.should == 0
        subject.updated.should == 0
        subject.deleted.should == 0
        subject.error_count.should == 0

      end

      it 'unretires any retired records' do
        previous_importer.import
        LandAndPropertyInformationRecord.first.retire!
        LandAndPropertyInformationRecord.last.retire!
        lambda do
          subject.import
        end.should_not change(
          LandAndPropertyInformationRecord.retired, :count
        ).by(-2)
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
        subject.deleted.should == 0
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
        subject.deleted.should == 0
        subject.error_count.should == 1

        subject.exceptions.length.should == 1
      end

    end


    context 'removes unreferenced LPIs from the database' do

      let(:filename)  { fixture_filename('lpi/EHC_LPMA_19710630.csv') }
      let!(:unseen_lpi) {
        FactoryGirl.create :land_and_property_information_record
      }

      it 'removes the unseen LPI record' do

        lambda do
          subject.import
        end.should change(
          LandAndPropertyInformationRecord.retired, :count
        ).by(1)

        subject.processed.should == 1
        subject.created.should == 1
        subject.updated.should == 0
        subject.deleted.should == 1
        subject.error_count.should == 0

        # This LPI should now be retired as it wasn't in the import
        LandAndPropertyInformationRecord.find(unseen_lpi.id).should be_retired
      end

    end

  end
end
