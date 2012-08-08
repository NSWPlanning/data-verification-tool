require 'lpi_spec_helper'

describe LPI::CSV do

  let(:filename)  { '/foo/bar.csv' }

  subject { described_class.new(filename) }

  its(:filename)  { should == filename }

  describe '#each' do

    let(:row)     { mock('row') }
    let(:record)  { mock('record') }

    before do
      ::CSV.stub(:foreach).with(filename, described_class.options).and_yield(row)
      LPI::Record.stub(:new).with(row) { record }
    end

    it "instantiates a record for each row in the CSV" do
      record.should_receive(:foo)
      subject.each do |r|
        r.foo
      end
    end
  end

end
