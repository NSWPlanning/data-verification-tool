shared_examples_for 'a data file for' do |base_module|

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
      base_module.const_get('CSV').should_receive(:new).with(filename).and_return(csv)
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

shared_examples_for 'a csv class' do

  its(:filename)  { should == filename }

  describe '#each' do

    let(:row)     { mock('row') }
    let(:line)    { 2 }
    let(:record)  { mock('record') }

    before do
      subject.stub(:options => options)
      ::CSV.stub(:foreach).with(filename, options).and_yield(row)
      subject.record_class.stub(:new).with(row, line) { record }
    end

    it "instantiates a record for each row in the CSV" do
      record.should_receive(:foo)
      subject.each do |r|
        r.foo
      end
    end

  end

end
