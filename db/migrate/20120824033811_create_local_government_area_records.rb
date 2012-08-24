class CreateLocalGovernmentAreaRecords < ActiveRecord::Migration
  def change
    create_table :local_government_area_records do |t|
      t.references :local_government_area
      t.string :date_of_update, :null => false
      t.string :council_id, :null => false
      t.string :if_partial_lot
      t.string :dp_lot_number
      t.string :dp_section_number
      t.string :dp_plan_number, :null => false
      t.string :ad_unit_no
      t.string :ad_st_no_from
      t.string :ad_st_no_to
      t.string :ad_st_name, :null => false
      t.string :ad_st_type
      t.string :ad_st_type_suffix
      t.string :ad_postcode, :null => false
      t.string :ad_suburb, :null => false
      t.string :ad_lga_name, :null => false
      t.string :land_area
      t.string :frontage
      t.string :lep_nsi_zone
      t.string :lep_si_zone, :null => false
      t.string :if_critical_habitat, :null => false
      t.string :if_wilderness, :null => false
      t.string :if_heritage_item, :null => false
      t.string :if_heritage_conservation_area, :null => false
      t.string :if_heritage_conservation_area_draft, :null => false
      t.string :if_coastal_water, :null => false
      t.string :if_coastal_lake, :null => false
      t.string :if_sepp14_with_100m_buffer, :null => false
      t.string :if_sepp26_with_100m_buffer, :null => false
      t.string :if_aquatic_reserve_with_100m_buffer, :null => false
      t.string :if_wet_land_with_100m_buffer, :null => false
      t.string :if_aboriginal_significance, :null => false
      t.string :if_biodiversity_significance, :null => false
      t.string :if_land_reserved_national_park, :null => false
      t.string :if_land_reserved_flora_fauna_geo, :null => false
      t.string :if_land_reserved_public_purpose, :null => false
      t.string :if_unsewered_land, :null => false
      t.string :if_acid_sulfate_soil, :null => false
      t.string :if_fire_prone_area, :null => false
      t.string :if_flood_control_lot, :null => false
      t.string :ex_buffer_area, :null => false
      t.string :ex_coastal_erosion_hazard, :null => false
      t.string :ex_ecological_sensitive_area, :null => false
      t.string :ex_protected_area, :null => false
      t.string :if_foreshore_area, :null => false
      t.string :ex_environmentally_sensitive_land, :null => false
      t.string :if_anef25, :null => false
      t.string :transaction, :null => false
      t.string :if_western_sydney_parkland, :null => false
      t.string :if_river_front, :null => false
      t.string :if_land_biobanking, :null => false
      t.string :if_sydney_water_special_area, :null => false
      t.string :if_sepp_alpine_resorts, :null => false
      t.string :if_siding_springs_18km_buffer, :null => false
      t.string :acid_sulfate_soil_class, :null => false
      t.string :if_mine_subsidence, :null => false
      t.string :if_local_heritage_item, :null => false
      t.string :if_orana_rep, :null => false

      t.timestamps
    end
    add_index :local_government_area_records,
      [:council_id, :local_government_area_id],
      :name => 'index_council_id_lga_id', :unique => true
  end
end
