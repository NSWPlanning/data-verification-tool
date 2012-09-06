class LocalGovernmentAreaRecord < ActiveRecord::Base

  include DVT::PlanLabelInstanceMethods

  belongs_to :land_and_property_information_record
  belongs_to :local_government_area

  attr_accessible :date_of_update, :council_id, :if_partial_lot,
    :dp_lot_number, :dp_section_number, :dp_plan_number, :ad_unit_no,
    :ad_st_no_from, :ad_st_no_to, :ad_st_name, :ad_st_type, :ad_st_type_suffix,
    :ad_postcode, :ad_suburb, :ad_lga_name, :land_area, :frontage,
    :lep_nsi_zone, :lep_si_zone, :if_critical_habitat, :if_wilderness,
    :if_heritage_item, :if_heritage_conservation_area,
    :if_heritage_conservation_area_draft, :if_coastal_water, :if_coastal_lake,
    :if_sepp14_with_100m_buffer, :if_sepp26_with_100m_buffer,
    :if_aquatic_reserve_with_100m_buffer, :if_wet_land_with_100m_buffer,
    :if_aboriginal_significance, :if_biodiversity_significance,
    :if_land_reserved_national_park, :if_land_reserved_flora_fauna_geo,
    :if_land_reserved_public_purpose, :if_unsewered_land,
    :if_acid_sulfate_soil, :if_fire_prone_area, :if_flood_control_lot,
    :ex_buffer_area, :ex_coastal_erosion_hazard, :ex_ecological_sensitive_area,
    :ex_protected_area, :if_foreshore_area, :ex_environmentally_sensitive_land,
    :if_anef25, :transaction_type, :if_western_sydney_parkland,
    :if_river_front, :if_land_biobanking, :if_sydney_water_special_area,
    :if_sepp_alpine_resorts, :if_siding_springs_18km_buffer,
    :acid_sulfate_soil_class, :if_mine_subsidence, :if_local_heritage_item,
    :if_orana_rep, :md5sum, :land_and_property_information_record_id,
    :local_government_area_id

  validates_presence_of :date_of_update, :council_id, :dp_plan_number,
    :ad_st_name, :ad_postcode, :ad_suburb, :ad_lga_name, :lep_si_zone,
    :if_critical_habitat, :if_wilderness, :if_heritage_item,
    :if_heritage_conservation_area, :if_heritage_conservation_area_draft,
    :if_coastal_water, :if_coastal_lake, :if_sepp14_with_100m_buffer,
    :if_sepp26_with_100m_buffer, :if_aquatic_reserve_with_100m_buffer,
    :if_wet_land_with_100m_buffer, :if_aboriginal_significance,
    :if_biodiversity_significance, :if_land_reserved_national_park,
    :if_land_reserved_flora_fauna_geo, :if_land_reserved_public_purpose,
    :if_unsewered_land, :if_acid_sulfate_soil, :if_fire_prone_area,
    :if_flood_control_lot, :ex_buffer_area, :ex_coastal_erosion_hazard,
    :ex_ecological_sensitive_area, :ex_protected_area, :if_foreshore_area,
    :ex_environmentally_sensitive_land, :if_anef25, :transaction_type,
    :if_western_sydney_parkland, :if_river_front, :if_land_biobanking,
    :if_sydney_water_special_area, :if_sepp_alpine_resorts,
    :if_siding_springs_18km_buffer, :acid_sulfate_soil_class,
    :if_mine_subsidence, :if_local_heritage_item, :if_orana_rep, :md5sum,
    :land_and_property_information_record_id

  validates_format_of :dp_plan_number, :with => /^(DP|SP)[0-9]+$/,
    :message => 'must begin with either DP or SP and be followed only by numbers'

  validates_exclusion_of :ad_st_no_from, :in => ['0'],
    :message => 'must not be "0"'

  #validates_uniqueness_of :dp_plan_number, :scope => :local_government_area_id,
  #  :if => :dp?

  scope :valid,   where(:is_valid => true)
  scope :invalid, where(:is_valid => false)
end
