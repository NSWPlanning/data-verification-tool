require 'spec_helper'

describe LocalGovernmentArea do

  describe '#to_s' do
    before do
      subject.name = 'LGA name'
    end
    its(:to_s)  { should == 'LGA name' }
  end

  describe '#find_land_and_property_information_record_by_title_reference' do

    let(:title_reference) { 'SP12345' }
    let(:lpi_record)    { mock('lpi_record') }

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

    let(:invalid) { mock('invalid') }

    before do
      subject.local_government_area_records.stub(:invalid => invalid)
    end

    it 'delegates to local_government_area_records.invalid' do
      invalid.should_receive(:delete_all)
      subject.delete_invalid_local_government_area_records
    end

  end

end
