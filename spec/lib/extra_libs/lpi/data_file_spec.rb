require 'lpi_spec_helper'

describe LPI::DataFile do

  let(:filename)  { '/foo/bar' }

  subject { described_class.new(filename) }

  its(:filename)  { should == filename }

  describe '#each' do

    let(:csv) { mock("csv") }
    let(:record)  { mock("record") }

    before do
      subject.stub(:csv => csv)
    end

    it "delegates to csv" do
      csv.should_receive(:each).and_yield(record)
      record.should_receive(:foo)
      subject.each do |r|
        r.foo
      end
    end
  end

  describe '#csv' do

    let(:csv) { mock("csv") }

    before do
      LPI::CSV.should_receive(:new).with(filename).and_return(csv)
    end

    it "should memoize the value" do
      subject.csv.should == csv
      subject.csv.should == csv
    end

  end

end
