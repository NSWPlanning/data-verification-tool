json.partial! "land_parcel_records/land_parcel", :parcel => @land_parcel_record

if @land_parcel_record.common_property?
  json.land_parcels(@land_parcel_record.lga_records.collect(&:land_parcel)) do |parcel|
    json.partial! "land_parcel_records/land_parcel", :parcel => parcel
  end
end
