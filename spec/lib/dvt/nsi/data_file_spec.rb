require 'lib_spec_helper'

describe DVT::NSI::DataFile do

  let(:filename)  { '/foo/ehc_lganame_lep_19710630.csv' }

  subject { described_class.new(filename, 'Camden') }

  its(:filename)  { should == filename }

  describe '#initialize' do
    it "should raise an error for a file not starting with ehc" do
      expect {
        described_class.new('foo_lpma_lep_19710630.csv', 'Camden')
      }.to raise_exception {
        DVT::NSI::DataFile::InvalidFilenameError
      }
    end

    it "should raise an error for a file without the csv extension" do
      expect {
        described_class.new('ehc_foo_lep_19710630.foo', 'Camden')
      }.to raise_exception {
        DVT::NSI::DataFile::InvalidFilenameError
      }
    end

    it "should raise an error for a file without the timestamp" do
      expect {
        described_class.new('ehc_foo_bar_lep.csv', 'Camden')
      }.to raise_exception {
        DVT::NSI::DataFile::InvalidFilenameError
      }
    end

    it "should raise an error for a file not having lep before the time" do
      expect {
        described_class.new('foo_lpma_lep_19710630.csv', 'Camden')
      }.to raise_exception {
        DVT::NSI::DataFile::InvalidFilenameError
      }
    end

    it "should not raise an error for a valid filename" do
      expect {
        described_class.new("ehc_camden_lep_20130221.csv", 'Camden')
      }.to_not raise_exception {
        DVT::NSI::DataFile::InvalidFilenameError
      }
    end
  end

  describe "#header_difference" do
    context "good data file" do
      let!(:nsi_good_data_file) {
        described_class.new(Rails.root.join('spec','fixtures','nsi','EHC_CAMDEN_LEP_20130310.csv'), 'Camden')
      }

      it "returns an empty array if there is no difference" do
        nsi_good_data_file.header_difference.should eq({})
      end
    end

    context "bad data file" do
      let!(:nsi_bad_data_file) {
        described_class.new(Rails.root.join('spec','fixtures','nsi','EHC_CAMDEN_LEP_20130311.csv'), 'Camden')
      }

      it "returns the difference of the provided and expected headers" do
        nsi_bad_data_file.header_difference.should eq({
          :date_of_update => "'date_of_update' should be 'Date_of_update'"
        })
      end
    end

  end

  describe '#lga_name' do
    its(:lga_name)  { should == 'lganame' }
  end

  it_should_behave_like 'a data file for', DVT::NSI
end
