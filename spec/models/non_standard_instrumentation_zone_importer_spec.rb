require 'spec_helper'

describe NonStandardInstrumentationZoneImporter do

  let!(:local_government_area) { FactoryGirl.create(:local_government_area, :name => "Wingecarribee") }
  let!(:email) { 'foo@bar.com' }
  let!(:user) { FactoryGirl.create(:user, :id => 2, :name => "Joe Smith", :email => email) }
  let!(:filename) { Rails.root.join('spec', 'fixtures', 'nsi', 'EHC_WINGECARRIBEE_LEP_20130310.csv') }

  describe "instance methods" do
    subject { described_class.new(filename, user) }

    before do
      subject.local_government_area = local_government_area
    end

    its(:filename) { should == filename }
    its(:user) { should == user }

    describe "import process" do
      let(:datafile)    { mock('datafile') }
      let(:batch)       { mock('batch') }
      let(:batch_size)  { 42 }
      let(:import_log)  { mock('import_log', :fail! => false) }

      before do
        DVT::NSI::DataFile.stub(:new).
          with(filename, local_government_area.name) { datafile }

        subject.should_receive(:before_import).ordered
        subject.should_receive(:after_import).ordered
        subject.stub(:dry_run)
        subject.stub(:import_log => import_log)
      end

      describe "#import" do
        context "when successful" do
          before do
            datafile.stub(:each_slice).with(batch_size).and_yield(batch)
            subject.should_receive(:transaction).and_yield
            subject.should_receive(:delete_unseen!)
            import_log.should_receive(:complete!)
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
  end

  describe "import results" do

    it "should create any new nsi zone records against the lga" do
      expect {
        NonStandardInstrumentationZoneImporter.import(local_government_area.id,
          filename, user.id, 10)
      }.to change { NonStandardInstrumentationZone.count }.by(30)
    end

    it "should create any new nsi zone records against the lga" do
      expect {
        NonStandardInstrumentationZoneImporter.import(local_government_area.id,
          filename, user.id, 10)
      }.to change { NonStandardInstrumentationZoneImportLog.count }.by(1)
    end

    it "should update any existing nsi zone records against the lga" do
      2.times {
        NonStandardInstrumentationZoneImporter.import(local_government_area.id,
          filename, user.id, 10)
      }
      NonStandardInstrumentationZone.count.should eq 30
    end

    it "should delete any missing nsi zone records against the lga" do
      nsi_zone = NonStandardInstrumentationZone.create({
        :local_government_area_id => local_government_area.id,
        :date_of_update => "20130311",
        :lep_nsi_zone => "123",
        :lep_si_zone => "123",
        :lep_name => "123",
        :council_id => "123"
      })

      NonStandardInstrumentationZoneImporter.import(local_government_area.id,
        filename, user.id, 10)

      NonStandardInstrumentationZone.count.should eq 30
      NonStandardInstrumentationZone.all.should_not include nsi_zone
    end

  end

  describe "class methods" do

    describe '.enqueue' do

      subject { described_class }

      let(:data_file) { mock('data_file') }
      let(:stored_filepath) { '/foo/bar.csv' }
      let(:target_directory) { '/foo' }

      before do
        subject.stub(:target_directory => target_directory)
      end

      specify do
        subject.should_receive(:store_uploaded_file).with(data_file, target_directory) {
          stored_filepath
        }
        QC.should_receive(:enqueue).with(
          'NonStandardInstrumentationZoneImporter.import', local_government_area.id,
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

      let(:importer) { mock('importer') }

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

  end

end
