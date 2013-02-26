unless @land_parcel_record.common_property?
  json.partial! "land_parcel_records/land_parcel", :parcel => @land_parcel_record
else
  json.partial! "land_parcel_records/land_parcel_simple", :parcel => @land_parcel_record
  json.lots(@land_parcel_record.lga_records.collect(&:land_parcel)) do |json, parcel|
    json.partial! "land_parcel_records/land_parcel_simple", :parcel => parcel
  end
end
