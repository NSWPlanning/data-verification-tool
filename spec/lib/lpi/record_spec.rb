require 'lpi_spec_helper'

describe LPI::Record do

  let(:row) { mock('row') }

  subject { described_class.new(row) }

  its(:row) { should == row }

  describe '#respond_to?' do
    pending
  end

  describe '#md5sum' do

    before do
      row.stub(:to_csv => "abc123\n")
    end

    # echo 'abc123' | md5sum - | cut -f 1 -d ' '
    # 2c6c8ab6ba8b9c98a1939450eb4089ed
    its(:md5sum)  { should == '2c6c8ab6ba8b9c98a1939450eb4089ed' }
  end

end
