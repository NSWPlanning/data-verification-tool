require 'spec_helper'

describe LandAndPropertyInformationLookup do

  let(:cadastre_id)   { '42' }
  let(:lga_name)      { 'BOGAN SHIRE' }
  let(:md5sum)        { 'abcdef01234567890' }
  let(:target_class)  { mock('target_class') }
  let(:record) {
    mock(
      'record', :cadastre_id => cadastre_id, :md5sum => md5sum,
      :lga_name => lga_name
    )
  }

  subject { described_class.new(target_class) }

  its(:target_class)  { should == target_class }

  describe '.has_record?' do

    let(:table) { mock('table') }

    before do
      subject.stub(:table => table)
    end

    context 'when table has a key for the record' do
      before do
        table.stub(:has_key?).with([cadastre_id,lga_name]) { true }
      end
      it { should have_record(record) }
    end

    context 'when table does not have a key for the record' do
      before do
        table.stub(:has_key?).with([cadastre_id, lga_name]) { false }
      end
      it { should_not have_record(record) }
    end

  end

  describe '.find_if_changed' do
    let(:id)  { 42 }
    context 'when checksums are identical' do
      before do
        subject.stub(:id_and_md5sum_for).with(record) { [id, md5sum] }
      end
      specify do
        subject.find_if_changed(record).should be_false
      end
    end

    context 'when checksums differ' do

      let(:lpi) { mock('lpi') }

      before do
        subject.stub(:id_and_md5sum_for).with(record) { [id, 'mismatch'] }
        subject.stub(:find).with(id) { lpi }
      end

      it "returns the matching active record instance" do
        subject.find_if_changed(record).should == lpi
      end
    end
  end

  describe '.id_and_md5sum_for' do

    let(:id)    { '999' }
    let(:table) { { [cadastre_id, lga_name] => [id, md5sum] } }

    before do
      subject.stub(:table => table)
    end

    specify do
      ar_id, ar_md5sum = subject.id_and_md5sum_for(record)
      ar_id.should == id
      ar_md5sum.should == record.md5sum
    end

  end

  describe '.find' do
    let(:id)  { '999' }
    let(:lpi) { mock('lpi') }
    it "calls find on the target class" do
      target_class.should_receive(:find).with(id) { lpi }
      subject.find(id).should == lpi
    end
  end

  describe '.add' do
    let(:id)  { 999 }
    let(:lpi) {
      mock(
        'lpi', :cadastre_id => cadastre_id, :id => id, :md5sum => md5sum,
        :lga_name => lga_name
      )
    }
    let(:table) { mock('table') }

    before do
      subject.stub(:table => table)
    end

    it 'adds an lpi to the lookup table' do
      table.should_receive(:[]=).with([cadastre_id, lga_name], [id.to_s, md5sum, true])
      subject.add(lpi)
    end
  end

  describe '#seen?' do

    let(:id)  { '999' }

    context 'when the record has been seen' do
      before do
        subject.stub(:table => { [cadastre_id, lga_name] => [id, md5sum, true]})
      end
      specify do
        subject.seen?(record).should be_true
      end
    end

    context 'when the record has not been seen' do
      before do
        subject.stub(:table => { cadastre_id => [id, md5sum, false]})
      end
      specify do
        subject.seen?(record).should be_false
      end
    end

  end

  describe '#mark_as_seen' do

    let(:id)  { '999' }

    context 'when the record has not been seen' do

      before do
        subject.stub(:table => { cadastre_id => [id, md5sum, false]})
      end

      it 'marks the record as seen' do
        subject.mark_as_seen(record)
        subject.seen?(record).should be_true
      end

    end

    context 'when the record has been seen' do
      before do
        subject.stub(:table => { [cadastre_id, lga_name] => [id, md5sum, true]})
      end
      it 'raises an exception' do
        lambda do
          subject.mark_as_seen(record)
        end.should raise_exception
      end
    end

  end

  describe '#unseen' do

    let(:unseen) {
        {
          ['1','LGA'] => ['42','abc123',false],
          ['2','LGA'] => ['43','abc123',false],
        }
    }
    let(:seen) {
        {
          ['3','LGA'] => ['44','abc123',true],
          ['4','LGA'] => ['45','abc123',true]
        }
    }

    before do
      subject.stub(:table)  { seen.merge(unseen) }
    end

    its(:unseen)  { should == unseen }
  end

  describe '#unseen_ids' do

    let(:unseen) {
        {
          ['1','LGA'] => ['42','abc123',false],
          ['2','LGA'] => ['43','abc123',false],
        }
    }

    before do
      subject.stub(:unseen => unseen)
    end

    its(:unseen_ids)  { should == ['42', '43'] }
  end
end
