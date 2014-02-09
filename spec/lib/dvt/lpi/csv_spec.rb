require 'lib_spec_helper'

describe DVT::LPI::CSV do

  let(:filename)  { '/foo/bar.csv' }
  let(:options)   { double('options') }

  subject { described_class.new(filename) }

  it_should_behave_like 'a csv class'

end
