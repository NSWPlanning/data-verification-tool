require 'spec_helper'

describe LocalGovernmentAreaLookup do

  describe '#find_id_from_lpi_alias' do

    let(:lpi_table)     { {} }
    let(:lga)       { mock('lga', :id => 42, :name => lga_name) }
    let(:lga_name)  { 'DUMMY_LGA_NAME' }

    before do
      subject.stub(:lpi_table => lpi_table)
    end

    context 'when LGA is present' do

      let(:lpi_table) { {lga_name => lga.id} }

      specify do
        subject.find_id_from_lpi_alias(lga_name).should == lga.id
      end

    end

    context 'when LGA is absent' do
      before do
        lpi_table.stub(:[]).with(lga_name) { nil }
      end

      specify do
        lambda do
          subject.find_id_from_lpi_alias('ABSENT')
        end.should raise_exception(LocalGovernmentAreaLookup::AliasNotFoundError)
      end

    end  

  end

  describe '#find_id_from_filename_alias' do

    let(:filename_table)  { {} }
    let(:lga)             { mock('lga', :id => 42, :name => lga_name) }
    let(:lga_name)        { 'DUMMY_LGA_NAME' }
    let(:filename_alias)  { 'FILENAME_COMPONENT'}

    before do
      subject.stub(:filename_table => filename_table)
    end

    context 'when alias is present' do

      let(:filename_table) { {filename_alias => lga.id} }

      specify do
        subject.find_id_from_filename_alias(filename_alias).should == lga.id
      end

    end

    context 'when alias is absent' do
      before do
        filename_table.stub(:[]).with(filename_alias) { nil }
      end

      specify do
        lambda do
          subject.find_id_from_filename_alias('ABSENT')
        end.should raise_exception(LocalGovernmentAreaLookup::AliasNotFoundError)
      end

    end  

  end

end
