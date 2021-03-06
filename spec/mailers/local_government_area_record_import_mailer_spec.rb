require 'spec_helper'

describe LocalGovernmentAreaRecordImportMailer do

  describe '#import_complete' do
    let(:email)                 { 'foo@example.com' }
    let(:from)                  { Rails.application.config.default_mail_from }
    let(:user)  {
      mock_model(
        User, :email => email
      )
    }
    let(:statistics)  {
      {
        :filename => '/foo/bar.csv', :processed => 99, :created => 66,
        :updated => 33, :deleted => 11, :error_count => 0
      }
    }
    let(:importer)  {
      double(
        'importer', :user => user, :statistics => statistics, :exceptions => []
      )
    }

    subject { ImportMailer.import_complete(importer) }

    specify do
      subject.to.should eq [email]
      subject.from.should eq([from])
      subject.subject.should eq('Import complete')
      subject.body.encoded.should match(/Filename:\s#{statistics[:filename]}/)
      subject.body.encoded.should match(/Processed:\s#{statistics[:processed]}/)
      subject.body.encoded.should match(/Created:\s#{statistics[:created]}/)
      subject.body.encoded.should match(/Updated:\s#{statistics[:updated]}/)
      subject.body.encoded.should match(/Deleted:\s#{statistics[:deleted]}/)
      subject.body.encoded.should match(/Error count:\s#{statistics[:error_count]}/)
    end
  end

  describe '#import_failed' do
    let(:email)                 { 'foo@example.com' }
    let(:from)                  { Rails.application.config.default_mail_from }
    let(:user)  {
      mock_model(
        User, :email => email
      )
    }
    let(:importer)  {
      double(
        'importer', :user => user, :filename => '/foo/bar.csv',
        :statistics => []
      )
    }
    let(:exception) { RuntimeError.new('Some error occurred') }

    subject { ImportMailer.import_failed(importer, exception) }

    specify do
      subject.to.should eq [email]
      subject.from.should eq([from])
      subject.subject.should eq('Import failed')
      subject.body.encoded.should match(
        /Your import of '#{importer.filename}' failed/
      )
    end
  end

  describe '#complete' do

    let(:import_log) {
      double('local_government_area_record_import_log', :id => 1)
    }

    let(:local_government_area_record_import_logs) {
      double('array', :successful => [import_log])
    }

    let(:local_government_area) {
      double('local_government_area',
        :id => 1,
        :name => "Fooville",
        :invalid_record_count => 0,
        :valid_record_count => 10,
        :local_government_area_record_import_logs => local_government_area_record_import_logs)
    }

    let(:email) { 'foo@bar.com' }
    let(:user)  {
      double('user',
        :id => 2,
        :name => "Joe Smith",
        :email => email)
    }

    let(:filename)              { '/foo/bar.csv' }
    let(:from)                  { Rails.application.config.default_mail_from }
    let(:statistics)  {
      {
        :filename => filename,
        :processed => 0,
        :created => 0,
        :updated => 0,
        :deleted => 0,
        :error_count => 0,
        :invalid_record_count => 0,
        :valid_record_count => 10
      }
    }

    let(:importer)  {
      LocalGovernmentAreaRecordImporter.new(filename, user)
    }

    before do
      DVT::LGA::DataFile.stub(:new).with(filename) { datafile }
      importer.stub(:dry_run)
      importer.stub(:local_government_area => local_government_area)
    end

    subject { LocalGovernmentAreaRecordImportMailer.complete(importer) }

    specify do
      subject.to.should eq [email]
      subject.from.should eq([from])
      subject.subject.should eq('Fooville Import complete')
      subject.body.encoded.should include("Filename: bar.csv")
      subject.body.encoded.should include("Records processed: #{statistics[:processed]}")
      subject.body.encoded.should include("Created: #{statistics[:created]}")
      subject.body.encoded.should include("Updated: #{statistics[:updated]}")
      subject.body.encoded.should include("Deleted: #{statistics[:deleted]}")
    end
  end

end
