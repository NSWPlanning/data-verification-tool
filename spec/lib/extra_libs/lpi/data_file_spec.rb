require 'lpi_spec_helper'

describe LPI::DataFile do

  let(:filename)  { '/foo/EHC_LPMA_19710630.csv' }

  subject { described_class.new(filename) }

  its(:filename)  { should == filename }

  describe '#initialize' do
    %w[
      FOO_LPMA_19710630.csv EHC_FOO_19710630.csv EHC_FOO_19710630.foo
      EHC_LPMA_abc123.csv
    ].each do |filename|

      specify "#{filename} should not be valid" do
        lambda do
          described_class.new(filename)
        end.should raise_exception(ArgumentError)
      end

    end
  end

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

  describe '#date' do
    its(:date) { should == Date.parse('30 Jun 1971') }
  end

end
