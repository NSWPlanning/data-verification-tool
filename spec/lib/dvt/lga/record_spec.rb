require 'lib_spec_helper'

describe DVT::LGA::Record do

  let(:row)   { double('row') }
  let(:line)  { 42 }

  subject { described_class.new(row, line) }

  it_should_behave_like 'a record'

  describe 'field methods' do
    described_class.header_fields.each do |field|
      method_name = field.downcase
      it { should respond_to method_name }
    end
  end

  describe '#title_reference' do

    before do
      subject.stub(
        :dp? => dp, :dp_lot_number => dp_lot_number,
        :dp_section_number => dp_section_number,
        :dp_plan_number => dp_plan_number
      )
    end

    let(:dp_lot_number)     { '448' }
    let(:dp_section_number) { '2' }
    let(:dp_plan_number)    { 'DP12345' }

    context 'when DP' do
      let(:dp)  { true }
      let(:sp)  { true }
      its(:title_reference) {
        should == "#{dp_lot_number}/#{dp_section_number}/#{dp_plan_number}"
      }
    end

    context 'when SP' do
      let(:dp)  { false }
      let(:sp)  { true }
      let(:dp_plan_number)  { "SP54321" }
      its(:title_reference) { should == "//#{dp_plan_number}" }
    end

    context 'when neither DP or SP' do
      let(:dp)  { false }
      let(:sp)  { false }
      its(:title_reference) { should be_nil }
    end

  end

  describe '#dp?' do

    context 'when dp_plan_number begins with DP' do
      before do
        subject.stub(:dp_plan_number => 'DP1234')
      end
      it { should be_dp }
    end

    context 'when dp_plan_number begins with SP' do
      before do
        subject.stub(:dp_plan_number => 'SP1234')
      end
      it { should_not be_dp }
    end

    context 'when dp_plan_number is nil' do
      before do
        subject.stub(:dp_plan_number => nil)
      end
      it { should_not be_dp }
    end
  end

  describe '#sp?' do

    context 'when dp_plan_number begins with DP' do
      before do
        subject.stub(:dp_plan_number => 'DP1234')
      end
      it { should_not be_sp }
    end

    context 'when dp_plan_number begins with SP' do
      before do
        subject.stub(:dp_plan_number => 'SP1234')
      end
      it { should be_sp }
    end

    context 'when dp_plan_number is nil' do
      before do
        subject.stub(:dp_plan_number => nil)
      end
      it { should_not be_sp }
    end

  end

  describe '#to_checksum_string' do

    let(:stripped_row)  { double('stripped_row') }
    let(:to_csv_string) { 'abc,123' }

    before do
      row.stub(:dup) { stripped_row }
      stripped_row.should_receive(:delete).with('Date_of_update').ordered
      stripped_row.should_receive(:to_csv).ordered { to_csv_string }
    end

    its(:to_checksum_string) { should == to_csv_string }    
  end

end
