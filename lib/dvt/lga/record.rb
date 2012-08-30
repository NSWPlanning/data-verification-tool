module DVT
  module LGA
    class Record < BaseRecord

      include PlanLabelInstanceMethods

      def self.fields
        @fields ||= [
          RecordField.new('Date_of_update'),
          RecordField.new('Council_ID'),
          RecordField.new('If_partial_lot'),
          RecordField.new('DP_lot_number'),
          RecordField.new('DP_section_number'),
          RecordField.new('DP_plan_number'),
          RecordField.new('Ad_unit_no'),
          RecordField.new('Ad_st_no_from'),
          RecordField.new('Ad_st_no_to'),
          RecordField.new('Ad_st_name'),
          RecordField.new('Ad_st_type'),
          RecordField.new('Ad_st_type_suffix'),
          RecordField.new('Ad_postcode'),
          RecordField.new('Ad_suburb'),
          RecordField.new('Ad_LGA_name'),
          RecordField.new('Land_area'),
          RecordField.new('Frontage'),
          RecordField.new('LEP_NSI_zone'),
          RecordField.new('LEP_SI_zone'),
          RecordField.new('If_critical_habitat'),
          RecordField.new('If_wilderness'),
          RecordField.new('If_heritage_item'),
          RecordField.new('If_heritage_conservation_area'),
          RecordField.new('If_heritage_conservation_area_draft'),
          RecordField.new('If_coastal_water'),
          RecordField.new('If_coastal_lake'),
          RecordField.new('If_SEPP14_with_100m_buffer'),
          RecordField.new('If_SEPP26_with_100m_buffer'),
          RecordField.new('If_aquatic_reserve_with_100m_buffer'),
          RecordField.new('If_wet_land_with_100m_buffer'),
          RecordField.new('If_Aboriginal_significance'),
          RecordField.new('If_biodiversity_significance'),
          RecordField.new('If_land_reserved_national_park'),
          RecordField.new('If_land_reserved_flora_fauna_geo'),
          RecordField.new('If_land_reserved_public_purpose'),
          RecordField.new('If_unsewered_land'),
          RecordField.new('If_acid_sulfate_soil'),
          RecordField.new('If_fire_prone_area'),
          RecordField.new('If_flood_control_lot'),
          RecordField.new('Ex_buffer_area'),
          RecordField.new('Ex_coastal_erosion_hazard'),
          RecordField.new('Ex_ecological_sensitive_area'),
          RecordField.new('Ex_protected_area'),
          RecordField.new('If_foreshore_area'),
          RecordField.new('Ex_environmentally_sensitive_land'),
          RecordField.new('If_ANEF25'),
          # transaction is a protected word in ActiveRecord
          RecordField.new('Transaction', :aliases => ['transaction_type']),
          RecordField.new('If_Western_Sydney_parkland'),
          RecordField.new('If_river_front'),
          RecordField.new('If_land_biobanking'),
          RecordField.new('If_Sydney_water_special_area'),
          RecordField.new('If_SEPP_Alpine_Resorts'),
          RecordField.new('If_Siding_Springs_18km_buffer'),
          RecordField.new('Acid_sulfate_soil_class'),
          RecordField.new('If_mine_subsidence'),
          RecordField.new('If_local_heritage_item'),
          RecordField.new('If_Orana_REP')
        ]
      end

      has_header_fields *header_fields

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

    end
  end
end
