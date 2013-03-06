require 'spec_helper'

describe LocalGovernmentAreaRecordImporter do

  let(:local_government_area) {
    FactoryGirl.create :local_government_area, :name => "Camden"
  }
  let(:email)                 { 'foo@bar.com' }
  let(:user)                  { mock('user', :id => 2, :name => "Joe Smith", :email => email) }
  let(:filename)              { Rails.root.join('spec','fixtures','test-data','ehc_camden_20120820.csv') }

  describe 'instance methods' do
    subject { described_class.new(filename, user) }

    before do
      subject.local_government_area = local_government_area
    end

    its(:filename)              { should == filename }
    its(:user)                  { should == user }


    describe 'import process' do

      let(:datafile)    { mock('datafile') }
      let(:batch)       { mock('batch') }
      let(:batch_size)  { 42 }
      let(:import_log)  { mock('import_log', :fail! => false) }
      let(:mailer)      { mock('mailer') }

      before do
        DVT::LGA::DataFile.stub(:new).
          with(filename, local_government_area.name) { datafile }
        LocalGovernmentAreaRecordImportLog.should_receive(:start!).
          with(subject) { import_log }
        subject.should_receive(:before_import).ordered
        subject.should_receive(:after_import).ordered
        subject.stub(:dry_run)
        subject.stub(:import_log => import_log)
      end

      describe "#import" do
        context 'when successful' do

          before do
            datafile.stub(:each_slice).with(batch_size).and_yield(batch)
            subject.should_receive(:transaction).and_yield
            subject.should_receive(:delete_unseen!)
            import_log.should_receive(:complete!)
            ImportMailer.stub(:lga_import_complete).with(subject) { mailer }
            mailer.should_receive(:deliver)
          end

          it "calls process_batch" do
            subject.should_receive(:process_batch).with(batch)
            expect do
              subject.import(batch_size)
            end.to change(subject, :import_run?).from(false).to(true)
          end

        end
      end
    end

    describe "#fail_import" do

      let(:mailer) { mock('mailer') }

      context "specific error cases" do

        let!(:importer_file_bad_name) {
          described_class.new(
            Rails.root.join('spec','fixtures','test-data','ehc_camden.csv'),
            user, :local_government_area => local_government_area)
        }

        it "should send a filename error email if a filename error occurs" do
          ImportMailer.stub(:lga_import_exception_filename_incorrect)
          ImportMailer.should_receive(:lga_import_exception_filename_incorrect)

          expect {
            importer_file_bad_name.import
          }.to raise_error {
            LocalGovernmentAreaRecordImporter::LgaFilenameMismatchError
          }
        end

        let!(:importer_file_bad_data) {
          described_class.new(
            Rails.root.join('spec','fixtures','test-data','ehc_camden_20120831.csv'),
            user, :local_government_area => local_government_area)
        }

        it "should send a unparseable error email if the file is unparseable" do
          ImportMailer.stub(:lga_import_exception_unparseable)
          ImportMailer.should_receive(:lga_import_exception_unparseable)

          expect {
            importer_file_bad_data.import
          }.to raise_error {
            LocalGovernmentAreaRecordImporter::LgaFileUnparseableError
          }
        end

        let!(:importer_file_empty) {
          described_class.new(
            Rails.root.join('spec','fixtures','test-data','ehc_camden_20120830.csv'),
            user, :local_government_area => local_government_area)
        }

        it "should send a file empty error email if the fils is empty" do
          ImportMailer.stub(:lga_import_exception_empty)
          ImportMailer.should_receive(:lga_import_exception_empty)

          expect {
            importer_file_empty.import
          }.to raise_error {
            LocalGovernmentAreaRecordImporter::LgaFileEmptyError
          }
        end

        let!(:importer_file_bad_headers) {
          described_class.new(
            Rails.root.join('spec','fixtures','test-data','ehc_camden_20120829.csv'),
            user, :local_government_area => local_government_area)
        }

        it "should send a headers invalid error if the files headers are invalid" do
          ImportMailer.stub(:lga_import_exception_header_errors)
          ImportMailer.should_receive(:lga_import_exception_header_errors)

          expect {
            importer_file_bad_headers.import
          }.to raise_error {
            LocalGovernmentAreaRecordImporter::LgaFileHeadersInvalidError
          }
        end
      end

      # context "other error cases" do
      #   let(:exception) { RuntimeError.new('My Error') }

      #   before do
      #     datafile.stub(:each_slice).with(batch_size).and_raise(exception)
      #     subject.stub(:import_log => import_log)
      #     import_log.should_receive(:fail!)
      #   end

      #   it "should send a generic import failed exception for other cases" do
      #     ImportMailer.stub(:import_failed) { mailer }
      #     mailer.should_receive(:deliver)
      #     expect { subject.import(batch_size) }.to raise_exception(RuntimeError)
      #   end
      # end
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

      let(:lookup)      { mock('lookup') }
      let(:record)      { mock('record') }
      let(:lpi_id)      { 42 }
      let(:has_record)  { true }

      before do
        subject.stub(:lpi_by_lga_lookup_for_record).with(record) {
          lookup
        }
        lookup.stub(
          :has_record?
        ).with(record) { has_record }
      end

      context 'when record is in lookup' do
        before do
          lookup.stub(
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

    describe '#lpi_by_lga_lookup_for_record' do

      let(:record)                { mock('record') }
      let(:sp_lpi_by_lga_lookup)  { mock('sp_lpi_by_lga_lookup') }
      let(:dp_lpi_by_lga_lookup)  { mock('dp_lpi_by_lga_lookup') }

      before do
        subject.stub(:sp_lpi_by_lga_lookup => sp_lpi_by_lga_lookup,
          :dp_lpi_by_lga_lookup => dp_lpi_by_lga_lookup)
      end

      context 'when record is SP' do

        before do
          record.stub(:sp? => true, :dp? => false)
        end

        it 'returns the sp_lpi_by_lga_lookup' do
          subject.lpi_by_lga_lookup_for_record(record).should == sp_lpi_by_lga_lookup
        end

      end

      context 'when record is DP' do

        before do
          record.stub(:sp? => false, :dp? => true)
        end

        it 'returns the dp_lpi_by_lga_lookup' do
          subject.lpi_by_lga_lookup_for_record(record).should == dp_lpi_by_lga_lookup
        end

      end

      context 'when record is neither DP or SP' do

        before do
          record.stub(:sp? => false, :dp? => false)
        end

        specify do
          subject.lpi_by_lga_lookup_for_record(record).should be_nil
        end
      end
    end

    describe '#check_import_filename!' do

      let(:data_file) { mock('data_file') }

      before do
        subject.stub(:data_file => data_file)
      end

      context 'when import filename does not match the LGA' do

        before do
          local_government_area.stub(
            :name => 'Foo', :filename_component => 'foo'
          )
          subject.data_file.stub(:lga_name => 'bar')
        end

        specify do
          expect {
            subject.check_import_filename!
          }.to raise_exception {
            LocalGovernmentAreaRecordImporter::LgaFilenameMismatchError
          }
        end

        context "the filename is invalid due to formatting" do

          let!(:bad_formatting_file) {
            Rails.root.join('spec','fixtures','test-data','ehc_camden.csv')
          }

          let!(:bad_formatting_import) {
            described_class.new(bad_formatting_file, user,
              :local_government_area => local_government_area)
          }

          it "should raise en error for the formatting" do
            begin
              bad_formatting_import.check_import_filename!
            rescue StandardError => e
              e.message.should eq "'#{bad_formatting_file}' is not a valid filename, required format is 'ehc_lganame_YYYYMMDD.csv'"
            end
          end
        end

        context "the filename is formatted correctly, but for the wrong council" do

          let!(:bad_name_file) {
            Rails.root.join('spec','fixtures','test-data','ehc_foo_20120820.csv')
          }

          let!(:bad_name_import) {
            described_class.new(bad_name_file, user,
              :local_government_area => local_government_area)
          }

          it "should raise an error with a message for the council mismatch" do
            begin
              bad_name_import.check_import_filename!
            rescue LocalGovernmentAreaRecordImporter::LgaFilenameMismatchError => e
              e.message.should eq "'#{filename}' is not a valid filename, 'camden' should be 'foo'."
            end
          end
        end

      end

      context 'when import filename matches the LGA' do
        before do
          local_government_area.stub(:filename_component => 'FOO')
          subject.data_file.stub(:lga_name => 'foo')
        end

        specify do
          expect { subject.check_import_filename! }.to_not raise_exception
        end
      end
    end

    describe '#check_import_file_not_empty!' do
      let!(:blank_filename) {
        Rails.root.join('spec','fixtures','test-data','ehc_camden_20120830.csv')
      }

      let!(:bad_import) { described_class.new(blank_filename, user) }

      it "should raise an error when the file is blank" do
        expect {
          bad_import.check_import_file_not_empty!
        }.to raise_exception {
          LocalGovernmentAreaRecordImporter::LgaFileEmptyError
        }
      end
    end

    describe '#check_import_file_headers' do
      let!(:bad_filename) {
        Rails.root.join('spec','fixtures','test-data','ehc_camden_20120829.csv')
      }

      let!(:bad_import) { described_class.new(bad_filename, user) }

      it "should raise an error when the file headers are misformed" do
        expect {
          bad_import.check_import_file_headers!
        }.to raise_exception {
          LocalGovernmentAreaRecordImporter::LgaFileHeadersInvalidError
        }
      end
    end

    describe '#before_import' do
      it 'calls delete_invalid_local_government_area_records' do
        subject.should_receive(:check_import_file_not_empty!).ordered
        subject.should_receive(:check_import_file_headers!).ordered
        subject.should_receive(:delete_invalid_local_government_area_records).ordered

        subject.before_import
      end
    end

    describe '#after_import' do
      it 'calls check_for_duplicate_dp_records' do
        subject.should_receive(:invalidate_duplicate_dp_records)
        subject.should_receive(:invalidate_inconsistent_sp_records)
        subject.should_receive(:add_exceptions_for_missing_dp_lpi_records)
        subject.should_receive(:add_exceptions_for_missing_sp_lpi_records)

        local_government_area.stub(:invalid_record_count => 42)
        local_government_area.should_receive(:invalid_records=)

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

    describe '#invalidate_inconsistent_sp_records' do

      before do
        subject.should_receive(:mark_inconsistent_sp_records_invalid) {
          ['SP1234','SP5678']
        }
      end

      it 'adds exceptions for all inconsistent SP records' do
        subject.invalidate_inconsistent_sp_records
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

    describe '#add_exceptions_for_missing_dp_lpi_records' do

      let(:missing_dp_lpi_record)  { 'DP1234' }

      before do
        subject.stub(:missing_dp_lpi_records => [missing_dp_lpi_record])
      end

      specify do
        subject.should_receive(:add_exception_to_base).with(
          an_instance_of(LocalGovernmentAreaRecordImporter::NotInLgaError)
        )
        subject.add_exceptions_for_missing_dp_lpi_records
      end

    end

    describe '#add_exceptions_for_missing_sp_lpi_records' do

      let(:missing_sp_lpi_record)  { 'SP1234' }

      before do
        subject.stub(:missing_sp_lpi_records => [missing_sp_lpi_record])
      end

      specify do
        subject.should_receive(:add_exception_to_base).with(
          an_instance_of(LocalGovernmentAreaRecordImporter::NotInLgaError)
        )
        subject.add_exceptions_for_missing_sp_lpi_records
      end

    end

    describe '#increment_exception_counters' do

      let(:record)    {
        mock('record', :has_address_errors? => true,
                       :missing_si_zone? => true,
                       :has_invalid_title_reference? => true)
      }
      let(:exception) { mock('exception', :record => record) }

      context 'with errors on dp_plan_number' do

        it 'increments invalid_title_references' do
          expect {
            subject.increment_exception_counters(exception)
          }.to change{
            subject.exception_counters[:invalid_title_reference]
          }.by(1)
        end

        it 'increments invalid_address' do
          expect {
            subject.increment_exception_counters(exception)
          }.to change{subject.exception_counters[:invalid_address]}.by(1)
        end

        it 'increments missing_si_zone' do
          expect {
            subject.increment_exception_counters(exception)
          }.to change{subject.exception_counters[:missing_si_zone]}.by(1)
        end

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
      subject.stub(:new).with(filename, user, {
        :local_government_area => local_government_area
      }) { importer }
      importer.should_receive(:import).ordered
      subject.import(local_government_area.id, filename, user.id)
    end

  end


  describe "failed import" do
    context "all of the records are bad" do
      let!(:filename) {
        Rails.root.join('spec','fixtures','test-data','ehc_camden_20120822.csv')
      }

      let!(:local_government_area) {
        FactoryGirl.create :local_government_area, :name => "Camden"
      }

      let(:user) {
        FactoryGirl.create :user
      }

      it "should raise an exception for the first batch failing" do
        expect {
          LocalGovernmentAreaRecordImporter.import(local_government_area.id,
            filename, user.id, 10)
        }.to raise_exception {
          LocalGovernmentAreaRecordImporter::LgaFirstBatchFailed
        }
      end


    end
  end

end
