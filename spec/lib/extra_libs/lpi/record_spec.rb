require 'lpi_spec_helper'

describe LPI::Record do

  let(:row)   { mock('row') }
  let(:line)  { 42 }

  subject { described_class.new(row, line) }

  its(:row)   { should == row }
  its(:line)  { should == line }

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
        subject.stub(:has_required_fields? => true)
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

  describe '#to_hash' do

    before do
      subject.stub(:bar => 'bar', :baz => 'baz')
      described_class.stub(:attributes) { [:bar, :baz] }
    end

    specify do
      subject.to_hash.keys.length.should == described_class.attributes.length
      subject.to_hash.each do |k, v|
        subject.send(k).should == v
      end
    end

  end

  describe '.attributes' do

    subject { described_class }

    specify do
      subject.attributes.should be_instance_of(Array)
      subject.attributes.length.should == subject.fields.length + subject.extra_attributes.length
    end

  end

end
