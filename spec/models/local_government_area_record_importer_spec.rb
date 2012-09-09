require 'spec_helper'

describe LocalGovernmentAreaRecordImporter do

  let(:local_government_area) { mock('local_government_area', :id => 1) }
  let(:user)                  { mock('user', :id => 2) }
  let(:filename)              { '/foo/bar' }

  describe 'instance methods' do
    subject { described_class.new(filename, user) }

    before do
      subject.local_government_area = local_government_area
    end

    its(:filename)              { should == filename }
    its(:user)                  { should == user }


    describe '#import' do

      let(:filename)    { '/foo/bar.csv' }
      let(:datafile)    { mock('datafile') }
      let(:batch)       { mock('batch') }
      let(:batch_size)  { 42 }
      let(:import_log)  { mock('import_log') }
      let(:mailer)      { mock('mailer') }
      
      before do
        DVT::LGA::DataFile.stub(:new).with(filename) { datafile }
        LocalGovernmentAreaRecordImportLog.should_receive(:start!).with(
          subject
        ) { import_log }
        subject.should_receive(:before_import).ordered
        subject.should_receive(:after_import).ordered
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

    describe '#extra_record_attributes' do

      let(:lpi_id)  { 42 }
      let(:lga_id)  { 84 }
      let(:record)  { mock('record') }

      before do
        subject.stub(:find_lpi_id_for).with(record) { lpi_id }
      end

      specify do
        subject.extra_record_attributes(record).should == {
          :land_and_property_information_record_id => lpi_id,
          :local_government_area_id => local_government_area.id
        }
      end

    end

    describe '#find_lpi_id_for' do

      let(:lpi_by_lga_lookup) {
        mock('lpi_by_lga_lookup')
      }
      let(:record)      { mock('record') }
      let(:lpi_id)      { 42 }
      let(:has_record)  { true }

      before do
        subject.stub(:lpi_by_lga_lookup => lpi_by_lga_lookup)
        lpi_by_lga_lookup.stub(
          :has_record?
        ).with(record) { has_record }
      end

      context 'when record is in lookup' do
        before do
          lpi_by_lga_lookup.stub(
            :id_and_md5sum_for
          ).with(record)  { [lpi_id, 'abc123'] }
        end

        specify do
          subject.find_lpi_id_for(record).should == lpi_id
        end
      end

      context 'when record is not in lookup' do
        let(:has_record)  { false }

        specify do
          subject.find_lpi_id_for(record).should be_nil
        end
      end

      context 'when local_government_ares is not set' do
        before do
          subject.stub(:local_government_area => nil)
        end

        specify do
          expect { subject.find_lpi_id_for(record) }.to raise_exception(
            RuntimeError
          )
        end
      end
    end

    describe '#before_import' do
      it 'calls delete_invalid_local_government_area_records' do
        subject.should_receive(:delete_invalid_local_government_area_records)
        subject.before_import
      end
    end

    describe '#after_import' do
      it 'calls check_for_duplicate_dp_records' do
        subject.should_receive(:invalidate_duplicate_dp_records)
        subject.after_import
      end
    end

    describe '#invalidate_duplicate_dp_records' do
      before do
        subject.stub(
          :duplicate_dp_records => [['DP1234', '5'], ['DP6789', '10']]
        )
        subject.should_receive(:mark_duplicate_dp_records_invalid)
      end

      it 'adds exceptions for all duplicate DP records' do
        subject.invalidate_duplicate_dp_records
        subject.exceptions[:base].length.should == 2
      end
    end

    describe '#delete_invalid_local_government_area_records' do

      it 'delegates to local_government_area' do
        local_government_area.should_receive(
          :delete_invalid_local_government_area_records
        )
        subject.delete_invalid_local_government_area_records
      end

    end

  end

  describe '.enqueue' do

    subject { described_class }

    let(:data_file)             { mock('data_file') }
    let(:stored_filepath)       { '/foo/bar.csv' }
    let(:target_directory)      { '/foo' }

    before do
      subject.stub(:target_directory => target_directory)
    end

    specify do
      subject.should_receive(:store_uploaded_file).with(data_file, target_directory) {
        stored_filepath
      }
      QC.should_receive(:enqueue).with(
        'LocalGovernmentAreaRecordImporter.import', local_government_area.id,
        stored_filepath, user.id
      )
      subject.enqueue(local_government_area, data_file, user)
    end

  end

  describe '.store_uploaded_file' do

    subject { described_class }

    let(:uploaded_file)     {
      mock('uploaded_file', :original_filename => 'bar', :tempfile => tempfile)
    }
    let(:tempfile)  { mock('tempfile', :path => '/tmp/flum') }
    let(:target_directory)  { '/foo' }
    let(:stored_filename) {
      File.join(target_directory, uploaded_file.original_filename)
    }

    specify do
      FileUtils.should_receive(:cp).with(tempfile.path, stored_filename)
      subject.store_uploaded_file(uploaded_file, target_directory).should == stored_filename
    end

  end

  describe '.import' do

    subject { described_class }

    let(:importer)              { mock('importer') }

    before do
      LocalGovernmentArea.stub(:find).with(local_government_area.id) {
        local_government_area
      }
      User.stub(:find).with(user.id) { user }
    end

    specify do
      subject.stub(:new).with(filename, user) { importer }
      importer.should_receive(:local_government_area=).with(local_government_area).ordered
      importer.should_receive(:import).ordered
      subject.import(local_government_area.id, filename, user.id)
    end

  end

end
