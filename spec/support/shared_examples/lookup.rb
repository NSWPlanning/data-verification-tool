shared_examples_for 'a lookup' do

  let(:id)            { '999' }
  let(:record)        { double('record', :md5sum => md5sum) }
  let(:md5sum)        { 'abcdef01234567890' }
  let(:lookup_key)    { double('lookup_key') }
  let(:table)         { double('table') }
  let(:target_class)  { double('target_class') }

  subject { described_class.new(target_class) }

  it { should respond_to(:table) }
  it { should respond_to(:lookup_key_for) }

  its(:target_class)  { should == target_class }

  describe '#has_record?' do

    before do
      subject.stub(:table => table)
      subject.stub(:lookup_key_for).with(record) { lookup_key }
    end

    context 'when table has a key for the record' do
      before do
        table.stub(:has_key?).with(lookup_key) { true }
      end
      it { should have_record(record) }
    end

    context 'when table does not have a key for the record' do
      before do
        table.stub(:has_key?).with(lookup_key) { false }
      end
      it { should_not have_record(record) }
    end

  end

  describe '#find' do
    let(:ar_record) { double('ar_record') }
    it "calls find on the target class" do
      target_class.should_receive(:find).with(id) { ar_record }
      subject.find(id).should == ar_record
    end
  end

  describe '.find_if_changed' do
    context 'when checksums are identical' do
      before do
        subject.stub(:id_and_md5sum_for).with(record) { [id, md5sum] }
      end
      specify do
        subject.find_if_changed(record).should be_false
      end
    end

    context 'when checksums differ' do

      let(:ar_record) { double('ar_record') }

      before do
        subject.stub(:id_and_md5sum_for).with(record) { [id, 'mismatch'] }
        subject.stub(:find).with(id) { ar_record }
      end

      it "returns the matching active record instance" do
        subject.find_if_changed(record).should == ar_record
      end
    end
  end

  describe '.id_and_md5sum_for' do

    let(:table)       { { lookup_key => [id, md5sum] } }

    before do
      subject.stub(:lookup_key_for).with(record) { lookup_key }
      subject.stub(:table => table)
    end

    specify do
      ar_id, ar_md5sum = subject.id_and_md5sum_for(record)
      ar_id.should == id
      ar_md5sum.should == record.md5sum
    end

  end

  describe '.add' do
    let(:ar_record) { double(
        'ar_record', :id => id, :md5sum => md5sum,
      )
    }

    before do
      subject.stub(:table => table)
      subject.stub(:lookup_key_for).with(ar_record)  { lookup_key }
    end

    it 'adds a record to the lookup table' do
      table.should_receive(:[]=).with(lookup_key, [id.to_s, md5sum, true])
      subject.add(ar_record)
    end
  end

  describe '#seen?' do

    before do
      subject.stub(:lookup_key_for).with(record) { lookup_key }
    end

    context 'when the record has been seen' do
      before do
        subject.stub(:table => { lookup_key => [id, md5sum, true]})
      end
      specify do
        subject.seen?(record).should be_true
      end
    end

    context 'when the record has not been seen' do
      before do
        subject.stub(:table => { lookup_key => [id, md5sum, false]})
      end
      specify do
        subject.seen?(record).should be_false
      end
    end

  end

  describe '#mark_as_seen' do

    before do
      subject.stub(:lookup_key_for).with(record) { lookup_key }
    end

    context 'when the record has not been seen' do

      before do
        subject.stub(:table => { lookup_key => [id, md5sum, false]})
      end

      it 'marks the record as seen' do
        subject.mark_as_seen(record)
        subject.seen?(record).should be_true
      end

    end

    context 'when the record has been seen' do
      before do
        subject.stub(:table => { lookup_key => [id, md5sum, true]})
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
          "foo" => ['42','abc123',false],
          "bar" => ['43','abc123',false],
        }
    }
    let(:seen) {
        {
          "baz" => ['44','abc123',true],
          "bun" => ['45','abc123',true]
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
          "foo" => ['42','abc123',false],
          "bar" => ['43','abc123',false],
        }
    }

    before do
      subject.stub(:unseen => unseen)
    end

    its(:unseen_ids)  { should == ['42', '43'] }
  end

end
