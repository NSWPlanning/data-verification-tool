json.dp do
  json.array!(@local_government_area.only_in_lpi_dp) do |dp|
    json.title_reference dp.title_reference
    json.CADID dp["cadastre_id"]
  end
end

json.sp do
  json.array!(@local_government_area.only_in_lpi_parent_sp) do |sp|
    json.title_reference sp.title_reference
    json.CADID sp["cadastre_id"] 
  end
end
