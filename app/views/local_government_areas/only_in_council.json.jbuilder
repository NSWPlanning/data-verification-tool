json.dp do
  json.array!(@local_government_area.only_in_council_dp) do |dp|
    json.title_reference dp.title_reference
    json.council_id dp["council_id"]
  end
end

json.sp do
  json.array!(@local_government_area.only_in_council_parent_sp) do |sp|
    json.title_reference sp.title_reference
    json.council_id sp["council_id"]  
  end
end
