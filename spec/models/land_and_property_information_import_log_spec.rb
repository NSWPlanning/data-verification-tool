require 'spec_helper'

describe LandAndPropertyInformationImportLog do

  its(:processed)   { should == 0 }
  its(:created)     { should == 0 }
  its(:updated)     { should == 0 }
  its(:error_count) { should == 0 }
  its(:success)     { should == false }
  its(:finished)    { should == false }

  describe '.start!' do

    subject { described_class }

    let(:import_log)  { double('import_log') }
    let(:importer)    { double('importer', :filename => filename, :user => user) }
    let(:user)        { double('user', :id => user_id) }
    let(:filename)    { '/foo/bar.csv' }
    let(:user_id)     { 42 }

    before do
      subject.should_receive(:create!).with(
        :filename => filename, :user_id => user_id
      ) { import_log }
      import_log.should_receive(:importer=).with(importer)
    end

    specify do
      subject.start!(importer).should == import_log
    end

  end

  describe '#complete!' do

    let(:importer)  {
      double(
        'importer', :processed => 1, :created => 2, :updated => 3,
        :error_count => 4
      )
    }
    let(:now) { double('now') }

    before do
      Time.stub(:now) { now }
      subject.stub(:importer => importer)
    end

    specify do
      subject.should_receive(:update_attributes).with(
        :processed => importer.processed, :created => importer.created, 
        :updated => importer.updated, :error_count => importer.error_count,
        :success => true, :finished => true, :finished_at => now
      )
      subject.complete!
    end

  end

  describe '#fail!' do

    let(:importer)  {
      double(
        'importer', :processed => 1, :created => 2, :updated => 3,
        :error_count => 4
      )
    }
    let(:now) { double('now') }

    before do
      Time.stub(:now) { now }
      subject.stub(:importer => importer)
    end

    specify do
      subject.should_receive(:update_attributes).with(
        :processed => importer.processed, :created => importer.created, 
        :updated => importer.updated, :error_count => importer.error_count,
        :success => false, :finished => true, :finished_at => now
      )
      subject.fail!
    end

  end

  describe '#importer' do

    let(:importer)  { double('importer') }

    specify do
      subject.importer = importer
      subject.importer.should == importer
    end

  end

  describe '#started_at' do

    let(:created_at)  { double('created_at') }

    before do
      subject.stub(:created_at => created_at)
    end

    it 'is aliased to created_at' do
      subject.started_at.should == created_at
    end
  end

end
