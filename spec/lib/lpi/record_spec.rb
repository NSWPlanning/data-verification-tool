require 'lpi_spec_helper'

describe LPI::Record do

  let(:row) { mock('row') }

  subject { described_class.new(row) }

  its(:row) { should == row }

  describe '#respond_to?' do
    pending
  end
end
