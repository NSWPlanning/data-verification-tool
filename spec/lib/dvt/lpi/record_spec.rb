require 'lib_spec_helper'

describe DVT::LPI::Record do

  let(:row)   { mock('row') }
  let(:line)  { 42 }

  subject { described_class.new(row, line) }

  it_should_behave_like 'a record'

  describe 'field methods' do
    described_class.header_fields.each do |field|
      method_name = field.downcase
      it { should respond_to method_name }
    end
  end

end
