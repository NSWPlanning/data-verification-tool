require 'spec_helper'

describe LocalGovernmentAreaLookup do

  describe '#find_id_from_lpi_alias' do

    let(:table)     { {} }
    let(:lga)       { mock('lga', :id => 42, :name => lga_name) }
    let(:lga_name)  { 'DUMMY_LGA_NAME' }

    before do
      subject.stub(:table => table)
    end

    context 'when LGA is present' do

      let(:table) { {lga_name => lga.id} }

      specify do
        subject.find_id_from_lpi_alias(lga_name).should == lga.id
      end

    end

    context 'when LGA is absent' do
      before do
        table.stub(:[]).with(lga_name) { nil }
      end

      specify do
        lambda do
          subject.find_id_from_lpi_alias('ABSENT')
        end.should raise_exception(LocalGovernmentAreaLookup::AliasNotFoundError)
      end

    end

  end

end
