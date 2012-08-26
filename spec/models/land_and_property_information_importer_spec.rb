require 'spec_helper'

describe LandAndPropertyInformationImporter do

  let(:target_class)  { mock('target_class') }
  let(:user)          { mock('user', :id => 999) }
  let(:filename)      { '/foo/bar.csv' }

  subject { described_class.new(filename, user) }

  its(:target_class)  { should == target_class }
  its(:filename)      { should == filename }
  its(:user)          { should == user }
  its(:exceptions)    { should == [] }
  its(:import_run?)   { should be_false }

  before do
    subject.stub(:target_class => target_class)
  end

  describe '#import' do

    let(:filename)    { '/foo/bar.csv' }
    let(:datafile)    { mock('datafile') }
    let(:batch)       { mock('batch') }
    let(:batch_size)  { 42 }
    let(:import_log)  { mock('import_log') }
    let(:mailer)      { mock('mailer') }
    
    before do
      LPI::DataFile.stub(:new).with(filename) { datafile }
      LandAndPropertyInformationImportLog.should_receive(:start!).with(
        subject
      ) { import_log }
    end

    context 'when successful' do

      before do
        datafile.stub(:each_slice).with(batch_size).and_yield(batch)
        subject.should_receive(:transaction).and_yield
        subject.should_receive(:delete_unseen!)
        subject.stub(:import_log => import_log)
        import_log.should_receive(:complete!)
        ImportMailer.stub(:import_complete).with(subject) { mailer }
        mailer.should_receive(:deliver)
      end

      it "calls process_batch" do
        subject.should_receive(:process_batch).with(batch)
        expect do
          subject.import(batch_size)
        end.to change(subject, :import_run?).from(false).to(true)
      end

    end

    context 'when an exception is thrown' do

      let(:exception)   { RuntimeError.new('My Error') }

      before do
        datafile.stub(:each_slice).with(batch_size).and_raise(exception)
        subject.stub(:import_log => import_log)
        import_log.should_receive(:fail!)
      end
      
      it 'sends a notification email' do
        ImportMailer.stub(:import_failed).with(subject, exception) { mailer }
        mailer.should_receive(:deliver)
        lambda do
          subject.import(batch_size)
        end.should raise_exception(RuntimeError)
      end

    end
  end

  describe '#process_batch' do

    let(:lpi_record_attributes) {
      FactoryGirl.attributes_for(:land_and_property_information_record)
    }
    let(:lpi_record)  {
      mock(
        'lpi_record',
        :cadastre_id  => 42,
        :to_hash      => lpi_record_attributes,
        :line         => 999
      )
    }
    let(:batch)       { [lpi_record] }
    let(:lpi)         { mock('lpi') }

    context 'when record has already been seen' do
      before do
        subject.stub(:seen!).with(lpi_record).and_raise(
          LandAndPropertyInformationLookup::RecordAlreadySeenError.new(
            lpi_record
          )
        )
      end

      specify do
        lambda do
          subject.process_batch(batch)
        end.should change(subject, :error_count).by(1)
        subject.exceptions.length.should == 1
      end
    end

    context 'when record has not been seen' do

      before do
        subject.stub(:seen!).with(lpi_record)
      end

      context 'when record already exists' do

        before do
          subject.stub(:has_record?).with(lpi_record) { true }
          subject.should_receive(:mark_as_seen).with(lpi_record) { true }
        end

        specify do
          subject.should_receive(:update_record_if_changed).with(lpi_record) {
            lpi
          }
          subject.process_batch(batch)
        end

      end

      context 'when record does not already exist' do

        let(:lpi_lookup)  { mock('lpi_lookup') }

        before do
          subject.stub(:has_record?).with(lpi_record) { false }
          subject.should_receive(:mark_as_seen).with(lpi) { true }
        end

        specify do
          subject.should_receive(:create_record!).with(lpi_record) { lpi }
          subject.process_batch(batch)
        end

      end

    end

  end

  describe '#create_record!' do

    let(:record)      { mock('record') }
    let(:attributes)  { mock(:attributes) }

    before do
      subject.stub(:record_attributes).with(record) { attributes }
      subject.should_receive(:create!).with(attributes)
    end

    specify do
      subject.create_record!(record)
    end

  end

  describe '#unseen' do

    let(:unseen_ids)  { [1,2,3,4] }
    let(:unseen)      { mock('unseen') }
    let(:import_run)  { true }

    before do
      subject.stub(:unseen_ids => unseen_ids, :import_run? => import_run)
      target_class.stub(:find).with(unseen_ids) { unseen }
    end

    it 'finds all the unseen records' do
      subject.unseen.should == unseen
    end

    context 'when import has not been run' do

      let(:import_run)  { false }

      specify do
        expect { subject.unseen }.to raise_exception(
          LandAndPropertyInformationImporter::ImportNotRunError
        )
      end

    end

  end

  describe '#delete_unseen!' do

    let(:unseen1) { mock('unseen1') }
    let(:unseen2) { mock('unseen2') }

    before do
      subject.stub(:unseen) { [unseen1, unseen2] }
    end

    specify do
      unseen1.should_receive(:destroy)
      unseen2.should_receive(:destroy)
      subject.delete_unseen!
      subject.deleted.should == 2
    end

  end

end
