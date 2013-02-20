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
json.record_information parcel.record_information
