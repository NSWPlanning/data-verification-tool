require 'lib_spec_helper'

describe DVT::LGA::DataFile do

  let(:filename)  { '/foo/ehc_camden_19710630.csv' }

  subject { described_class.new(filename, 'Camden') }

  its(:filename)  { should == filename }

  describe '#initialize' do
    it "should raise an error for a file not starting with ehc" do
      expect {
        described_class.new('foo_lpma_19710630.csv', 'Camden')
      }.to raise_exception {
        DVT::LGA::DataFile::InvalidFilenameError
      }
    end

    it "should raise an error for a file without the csv extension" do
      expect {
        described_class.new('ehc_foo_19710630.foo', 'Camden')
      }.to raise_exception {
        DVT::LGA::DataFile::InvalidFilenameError
      }
    end

    it "should raise an error for a file without the timestamp" do
      expect {
        described_class.new('ehc_foo_bar.csv', 'Camden')
      }.to raise_exception {
        DVT::LGA::DataFile::InvalidFilenameError
      }
    end

    it "should not raise an error for a valid filename" do
      expect {
        described_class.new("ehc_camden_20130221.csv", 'Camden')
      }.to_not raise_exception {
        DVT::LGA::DataFile::InvalidFilenameError
      }
    end
  end

  describe "#header_difference" do
    context "good data file" do
      let!(:lga_good_data_file) {
        described_class.new(Rails.root.join('spec','fixtures','test-data','ehc_camden_20120820.csv'), 'Camden')
      }

      it "returns an empty array if there is no difference" do
        lga_good_data_file.header_difference.should eq({})
      end
    end

    context "bad data file" do
      let!(:lga_bad_data_file) {
        described_class.new(Rails.root.join('spec','fixtures','test-data','ehc_camden_20120829.csv'), 'Camden')
      }

      it "returns the difference of the provided and expected headers" do
        lga_bad_data_file.header_difference.should eq({
          :ep_si_zone => "'EP_SI_zone' should not be present",
          :lep_si_zone => "'LEP_SI_zone' is missing"
        })
      end
    end

  end

  describe '#lga_name' do
    its(:lga_name) { should eq 'camden' }
  end

  it_should_behave_like 'a data file for', DVT::LGA
end
