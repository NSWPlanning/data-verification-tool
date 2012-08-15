require 'spec_helper'

describe ImportMailer do

  describe '#import_complete' do
    let(:email)                 { 'foo@example.com' }
    let(:from)                  { Rails.application.config.default_mail_from }
    let(:user)  {
      mock_model(
        User, :email => email
      )
    }
    let(:importer)  {
      mock(
        'importer', :user => user, :filename => '/foo/bar.csv',
        :processed => 99, :created => 66, :updated => 33, :errors => 0,
        :exceptions => []
      )
    }

    subject { ImportMailer.import_complete(importer) }

    specify do
      subject.to.should == [email]
      subject.from.should eq([from])
      subject.subject.should eq('Import complete')
      subject.body.encoded.should match(/Filename:\s#{importer.filename}/)
      subject.body.encoded.should match(/Processed:\s#{importer.processed}/)
      subject.body.encoded.should match(/Created:\s#{importer.created}/)
      subject.body.encoded.should match(/Updated:\s#{importer.updated}/)
      subject.body.encoded.should match(/Errors:\s#{importer.errors}/)
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
      mock(
        'importer', :user => user, :filename => '/foo/bar.csv'
      )
    }
    let(:exception) { RuntimeError.new('Some error occurred') }

    subject { ImportMailer.import_failed(importer, exception) }

    specify do
      subject.to.should == [email]
      subject.from.should eq([from])
      subject.subject.should eq('Import failed')
      subject.body.encoded.should match(
        /Your import of '#{importer.filename}' failed/
      )
    end
  end

end
