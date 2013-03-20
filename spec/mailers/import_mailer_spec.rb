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
    let(:statistics)  {
      {
        :filename => '/foo/bar.csv', :processed => 99, :created => 66,
        :updated => 33, :deleted => 11, :error_count => 0
      }
    }
    let(:importer)  {
      mock(
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
      mock(
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

end
