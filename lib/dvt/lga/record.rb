module DVT
  module LGA
    class Record < DVT::Base::Record

      include PlanLabelInstanceMethods

      has_field 'Date_of_update'
      has_field 'Council_ID'
      has_field 'If_partial_lot'
      has_field 'DP_lot_number'
      has_field 'DP_section_number'
      has_field 'DP_plan_number'
      has_field 'Ad_unit_no'
      has_field 'Ad_st_no_from'
      has_field 'Ad_st_no_to'
      has_field 'Ad_st_name'
      has_field 'Ad_st_type'
      has_field 'Ad_st_type_suffix'
      has_field 'Ad_postcode'
      has_field 'Ad_suburb'
      has_field 'Ad_LGA_name'
      has_field 'Land_area'
      has_field 'Frontage'
      has_field 'LEP_NSI_zone'
      has_field 'LEP_SI_zone'
      has_field 'If_critical_habitat'
      has_field 'If_wilderness'
      has_field 'If_heritage_item'
      has_field 'If_heritage_conservation_area'
      has_field 'If_heritage_conservation_area_draft'
      has_field 'If_coastal_water'
      has_field 'If_coastal_lake'
      has_field 'If_SEPP14_with_100m_buffer'
      has_field 'If_SEPP26_with_100m_buffer'
      has_field 'If_aquatic_reserve_with_100m_buffer'
      has_field 'If_wet_land_with_100m_buffer'
      has_field 'If_Aboriginal_significance'
      has_field 'If_biodiversity_significance'
      has_field 'If_land_reserved_national_park'
      has_field 'If_land_reserved_flora_fauna_geo'
      has_field 'If_land_reserved_public_purpose'
      has_field 'If_unsewered_land'
      has_field 'If_acid_sulfate_soil'
      has_field 'If_fire_prone_area'
      has_field 'If_flood_control_lot'
      has_field 'Ex_buffer_area'
      has_field 'Ex_coastal_erosion_hazard'
      has_field 'Ex_ecological_sensitive_area'
      has_field 'Ex_protected_area'
      has_field 'If_foreshore_area'
      has_field 'Ex_environmentally_sensitive_land'
      has_field 'If_ANEF25'
      # transaction is a protected word in ActiveRecord
      has_field 'Transaction', :aliases => ['transaction_type']
      has_field 'If_Western_Sydney_parkland'
      has_field 'If_river_front'
      has_field 'If_land_biobanking'
      has_field 'If_Sydney_water_special_area'
      has_field 'If_SEPP_Alpine_Resorts'
      has_field 'If_Siding_Springs_18km_buffer'
      has_field 'Acid_sulfate_soil_class'
      has_field 'If_mine_subsidence'
      has_field 'If_local_heritage_item'
      has_field 'If_Orana_REP'

      # Extra attributes that are not included in the CSV data, but are relevant
      # to the records
      def self.extra_attributes
        [:md5sum]
      end

      def title_reference
        if dp?
          "#{dp_lot_number}/#{dp_section_number}/#{dp_plan_number}"
        elsif sp?
          "//#{dp_plan_number}"
        end
      end

      def to_checksum_string
        stripped_row = row.dup
        stripped_row.delete('Date_of_update')
        stripped_row.to_csv
      end

    end
  end
end
