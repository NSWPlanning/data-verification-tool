require 'spec_helper'

describe LandAndPropertyInformationImporter do

  let(:target_class)  { mock('target_class') }
  let(:user)          { mock('user') }
  let(:filename)      { '/foo/bar.csv' }

  subject { described_class.new(filename, user) }

  its(:target_class)  { should == target_class }
  its(:filename)      { should == filename }
  its(:user)          { should == user }

  before do
    subject.stub(:target_class => target_class)
  end

  describe '#import' do

    let(:filename)    { '/foo/bar.csv' }
    let(:datafile)    { mock('datafile') }
    let(:batch)       { mock('batch') }
    let(:batch_size)  { 42 }

    before do
      LPI::DataFile.stub(:new).with(filename) { datafile }
      datafile.stub(:each_slice).with(batch_size).and_yield(batch)
      subject.should_receive(:transaction).and_yield
    end

    it "calls process_batch" do
      subject.should_receive(:process_batch).with(batch)
      subject.import(batch_size)
    end
  end

  describe '#process_batch' do

    let(:lpi_record_attributes) {
      FactoryGirl.attributes_for(:land_and_property_information_record)
    }
    let(:lpi_record)  { mock('lpi_record', :to_hash => lpi_record_attributes) }
    let(:batch)       { [lpi_record] }

    context 'when record already exists' do

      before do
        subject.stub(:has_record?).with(lpi_record) { true }
      end

      specify do
        subject.should_receive(:update_record_if_changed).with(lpi_record)
        subject.process_batch(batch)
      end

    end

    context 'when record does not already exist' do

      let(:lookup)  { mock('lookup') }
      let(:lpi)     { mock('lpi') }

      before do
        subject.stub(:has_record?).with(lpi_record) { false }
        subject.stub(:lookup => lookup)
      end

      specify do
        subject.should_receive(:create!).with(lpi_record.to_hash) { lpi }
        lookup.should_receive(:add).with(lpi)
        subject.process_batch(batch)
      end

    end

  end
end
