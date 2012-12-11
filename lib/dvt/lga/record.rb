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
# TODO: Metadata: Read required fields from LGA-specific metadata form.
#       All fields that are required must be present.
      has_field 'If_critical_habitat',                  required: false
      has_field 'If_wilderness',                        required: false
      has_field 'If_heritage_item',                     required: false
      has_field 'If_heritage_conservation_area',        required: false
      has_field 'If_heritage_conservation_area_draft',  required: false
      has_field 'If_coastal_water',                     required: false
      has_field 'If_coastal_lake',                      required: false
      has_field 'If_SEPP14_with_100m_buffer',           required: false
      has_field 'If_SEPP26_with_100m_buffer',           required: false
      has_field 'If_aquatic_reserve_with_100m_buffer',  required: false
      has_field 'If_wet_land_with_100m_buffer',         required: false
      has_field 'If_Aboriginal_significance',           required: false
      has_field 'If_biodiversity_significance',         required: false
      has_field 'If_land_reserved_national_park',       required: false
      has_field 'If_land_reserved_flora_fauna_geo',     required: false
      has_field 'If_land_reserved_public_purpose',      required: false
      has_field 'If_unsewered_land',                    required: false
      has_field 'If_acid_sulfate_soil',                 required: false
      has_field 'If_fire_prone_area',                   required: false
      has_field 'If_flood_control_lot',                 required: false
      has_field 'Ex_buffer_area',                       required: false
      has_field 'Ex_coastal_erosion_hazard',            required: false
      has_field 'Ex_ecological_sensitive_area',         required: false
      has_field 'Ex_protected_area',                    required: false
      has_field 'If_foreshore_area',                    required: false
      has_field 'Ex_environmentally_sensitive_land',    required: false
      has_field 'If_ANEF25',                            required: false
      # transaction is a protected word in ActiveRecord
      has_field 'Transaction', :aliases => ['transaction_type'], required: false
      has_field 'If_Western_Sydney_parkland',           required: false
      has_field 'If_river_front',                       required: false
      has_field 'If_land_biobanking',                   required: false
      has_field 'If_Sydney_water_special_area',         required: false
      has_field 'If_SEPP_Alpine_Resorts',               required: false
      has_field 'If_Siding_Springs_18km_buffer',        required: false
      has_field 'Acid_sulfate_soil_class',              required: false
      has_field 'If_mine_subsidence',                   required: false
      has_field 'If_local_heritage_item',               required: false
      has_field 'If_Orana_REP',                         required: false

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
