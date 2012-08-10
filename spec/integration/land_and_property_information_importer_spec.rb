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

      end

    end

    it 'imports with duplicate records' do
      pending
    end

    it 'removes unreferenced LPIs from the database'

  end
end
