json.title_reference parcel.title_reference
valid = parcel.valid?
json.valid valid
if !valid
  json.errors do
    json.error_messages parcel.errors
    json.attribute_errors parcel.attribute_error_information
    json.inconsistent_attributes parcel.inconsistent_attribute_information
  end
end
