require 'lpi_spec_helper'

describe LPI::Record do

  let(:row) { mock('row') }

  subject { described_class.new(row) }

  its(:row) { should == row }

  describe 'field methods' do
    described_class.header_fields.each do |field|
      method_name = field.downcase
      it { should respond_to method_name }
    end
  end

  describe '#md5sum' do

    before do
      row.stub(:to_csv => "abc123\n")
    end

    # echo 'abc123' | md5sum - | cut -f 1 -d ' '
    # 2c6c8ab6ba8b9c98a1939450eb4089ed
    its(:md5sum)  { should == '2c6c8ab6ba8b9c98a1939450eb4089ed' }
  end

  describe '#valid?' do

    context 'when required fields are all present' do
      before do
        subject.stub(:required_fields_present? => true)
      end
      it { should be_valid }
    end

    context 'when required fields are not all present' do
      before do
        subject.stub(:has_required_fields? => false)
      end
      it { should_not be_valid }
    end

  end

  describe '#has_required_fields?' do

    before do
      described_class.stub(:required_fields => ['FOO', 'BAR'])
    end

    specify do
      row.stub(:include?).with('FOO') { true }
      row.stub(:include?).with('BAR') { true }
      subject.should have_required_fields
      row.stub(:include?).with('BAR') { false }
      subject.should_not have_required_fields
    end
  end
end
