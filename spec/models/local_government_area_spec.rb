require 'spec_helper'

describe LocalGovernmentArea do

  it { should respond_to :non_standard_instrumentation_zones }

  describe '#to_s' do
    before do
      subject.name = 'LGA name'
    end
    its(:to_s)  { should == 'LGA name' }
  end

  describe '#find_land_and_property_information_record_by_title_reference' do

    let(:title_reference) { 'SP12345' }
    let(:lpi_record)    { double('lpi_record') }

    before do
      subject.land_and_property_information_records.stub(
        :find_by_title_reference
      ).with(title_reference) { lpi_record }
    end

    it 'delegates to land_and_property_information_records' do
      subject.find_land_and_property_information_record_by_title_reference(
        title_reference
      ).should == lpi_record
    end

  end

  describe '#delete_invalid_local_government_area_records' do

    let(:invalid) { double('invalid') }

    before do
      subject.local_government_area_records.stub(:invalid => invalid)
    end

    it 'delegates to local_government_area_records.invalid' do
      invalid.should_receive(:delete_all)
      subject.delete_invalid_local_government_area_records
    end

  end

  describe '#invalid_record_count' do

    let(:local_government_area_records) {
      double(
        'local_government_area_records',
        :invalid_count => invalid_record_count
      )
    }
    let(:invalid_record_count)  { 42 }

    before do
      subject.stub(
        :local_government_area_records => local_government_area_records
      )
    end

    its(:invalid_record_count)  { should == invalid_record_count }
  end

  describe '#valid_record_count' do

    let(:local_government_area_records) {
      double(
        'local_government_area_records',
        :valid_count => valid_record_count
      )
    }
    let(:valid_record_count)  { 42 }

    before do
      subject.stub(
        :local_government_area_records => local_government_area_records
      )
    end

    its(:valid_record_count)  { should == valid_record_count }

  end

  describe '#mark_inconsistent_sp_records_invalid' do

    let(:inconsistent_sp_records) { ['SP123','SP234'] }
    let(:connection)              { double('connection') }

    before do
      subject.stub(
        :inconsistent_sp_records => inconsistent_sp_records,
        :connection => connection, :id => 42
      )
    end

    specify do
      connection.should_receive(:query)
      subject.mark_inconsistent_sp_records_invalid.should == inconsistent_sp_records
    end
  end

  describe '#filename_component' do
    specify do
      subject.stub(:name => 'Foo Bar')
      subject.filename_component.should == 'foo_bar'
      subject.stub(:filename_alias => '')
      subject.filename_component.should == 'foo_bar'
      subject.stub(:filename_alias => 'Boo Baz')
      subject.filename_component.should == 'boo_baz'
    end
  end

  describe '#lpi_alias' do
    specify do
      subject.stub(:name => 'Bad Ger')
      subject.lpi_alias.should == nil
      subject.stub(:lpi_alias => '')
      subject.lpi_alias.should == ''
      subject.stub(:lpi_alias => 'Hedge Hog')
      subject.lpi_alias.should == 'Hedge Hog'
    end
  end
end
