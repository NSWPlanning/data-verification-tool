json.title_reference parcel.title_reference

valid = parcel.valid?
json.valid valid
if !valid
  json.errors do
    json.error_messages parcel.errors
    json.attribute_errors parcel.attribute_error_information
    json.inconsistent_attributes  parcel.inconsistent_attribute_information
  end
end

json.address parcel.address_information
json.land_based_information parcel.land_information

json.raw_record parcel.raw_record_information

json.record_information do |json|
  json.council_file_date_of_update parcel.lga_record.date_of_update.to_time.iso8601
  json.council_id parcel.lga_record.council_id
end
