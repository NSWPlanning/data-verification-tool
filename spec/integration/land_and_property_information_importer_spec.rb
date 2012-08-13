require 'spec_helper'

describe LandAndPropertyInformationImporter do

  include LpiSpecHelpers

  let(:user)      { FactoryGirl.create(:admin_user) }
  let(:filename)  { fixture_filename('lpi/EHC_LPMA_19710630.csv') }

  subject { described_class.new(filename, user) }

  describe '.import' do

    it 'imports the LPI records' do

      lambda do
        subject.import
      end.should change(LandAndPropertyInformationRecord, :count).by(1)

      subject.processed.should == 1
      subject.created.should == 1
      subject.updated.should == 0
      subject.errors.should == 0

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
        subject.errors.should == 0

      end

    end

    context 'imports with duplicate records' do

      let(:filename)  { fixture_filename('lpi/EHC_LPMA_19710701.csv') }

      it 'skips the duplicate and registers the error' do

        lambda do
          subject.import
        end.should change(LandAndPropertyInformationRecord, :count).by(1)

        subject.processed.should == 2
        subject.created.should == 1
        subject.updated.should == 0
        subject.errors.should == 1

        subject.exceptions.length.should == 1
      end

    end

    it 'removes unreferenced LPIs from the database'

  end
end
