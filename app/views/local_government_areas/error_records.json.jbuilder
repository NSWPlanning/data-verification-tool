json.invalid_title_reference do
  json.array!(@local_government_area.local_government_area_records.invalid_title_reference) do |r|
    json.title_reference r.title_reference
    json.council_id r.council_id
  end
end

json.duplicate_dp do
  json.array!(@local_government_area.duplicate_dp_records) do |r|
    json.title_reference r[0]
    json.occurrences r[1]
  end
end

json.invalid_address do
  json.array!(@local_government_area.local_government_area_records.invalid_address) do |r|
    json.title_reference r.title_reference
    json.address_errors do
      json.array!(r.address_errors) do |error|
        json.field error[0]
        json.error error[1] 
      end
    end
  end
end

json.missing_si_zone do
  json.array!(@local_government_area.local_government_area_records.missing_si_zone) do |r|
    json.title_reference r.title_reference
    json.council_id r.council_id
  end
end


json.inconsistent_attributes do
  json.array!(@local_government_area.inconsistent_sp_records) do |dp_plan_number|
    json.dp_plan_number dp_plan_number
    json.inconsistent_attributes @local_government_area.inconsistent_sp_attributes_for(dp_plan_number)
  end
end
