module DVT
  module LGA
    class DataFile < DVT::Base::DataFile

      class InvalidFilenameError < StandardError; end

      attr_reader :lga_name

      def initialize(filename, local_government_area_record_name)
        @lga_name = local_government_area_record_name
        super(filename)
      end

      def csv_class
        DVT::LGA::CSV
      end

      def header_difference
        zipped_headers = expected_headers.zip csv.headers
        {}.tap do |result|
          zipped_headers.each_with_index do |headers, index|

            # If they're the same thing, then something is wrong
            unless headers.uniq.length == 1
              expected = headers.first
              got = headers.last

              if got.blank?
                message = "'#{expected}' is missing"
              else
                if expected.downcase == got.downcase
                  message = "\'#{got}\' should be \'#{expected}\'"
                elsif !expected_headers.collect(&:downcase).include?(got.downcase)
                  message = "\'#{got}\' should not be present"
                else
                  # if got == expected_headers[index+1] && (index != expected_headers.length)
                  #   message = "'#{expected}' is missing"
                  # else
                    message = "\'#{got}\' should be swapped with \'#{expected}\'"
                  # end
                end
              end
              result[:column_errors] ||= {}
              result[:column_errors].merge!({
                index => {
                  :expected => expected,
                  :got => got,
                  :message => message
                }
              })
            end
          end
        end
      end

      protected

      def expected_headers
        [
          "Date_of_update",
          "Council_ID",
          "If_partial_lot",
          "DP_lot_number",
          "DP_section_number",
          "DP_plan_number",
          "Ad_unit_no",
          "Ad_st_no_from",
          "Ad_st_no_to",
          "Ad_st_name",
          "Ad_st_type",
          "Ad_st_type_suffix",
          "Ad_postcode",
          "Ad_suburb",
          "Ad_LGA_name",
          "Land_area",
          "Frontage",
          "LEP_NSI_zone",
          "LEP_SI_zone",
          "If_critical_habitat",
          "If_wilderness",
          "If_heritage_item",
          "If_heritage_conservation_area",
          "If_heritage_conservation_area_draft",
          "If_coastal_water",
          "If_coastal_lake",
          "If_SEPP14_with_100m_buffer",
          "If_SEPP26_with_100m_buffer",
          "If_aquatic_reserve_with_100m_buffer",
          "If_wet_land_with_100m_buffer",
          "If_Aboriginal_significance",
          "If_biodiversity_significance",
          "If_land_reserved_national_park",
          "If_land_reserved_flora_fauna_geo",
          "If_land_reserved_public_purpose",
          "If_unsewered_land",
          "If_acid_sulfate_soil",
          "If_fire_prone_area",
          "If_flood_control_lot",
          "Ex_buffer_area",
          "Ex_coastal_erosion_hazard",
          "Ex_ecological_sensitive_area",
          "Ex_protected_area",
          "If_foreshore_area",
          "Ex_environmentally_sensitive_land",
          "If_ANEF25",
          "Transaction",
          "If_Western_Sydney_parkland",
          "If_river_front",
          "If_land_biobanking",
          "If_Sydney_water_special_area",
          "If_SEPP_Alpine_Resorts",
          "If_Siding_Springs_18km_buffer",
          "Acid_sulfate_soil_class",
          "If_mine_subsidence",
          "If_local_heritage_item",
          "If_Orana_REP"
        ]
      end

      def parse_filename(filename)
        @filename = filename
        basename = File.basename(filename)
        ehc,*lga_name_array,date_string,suffix = basename.split(/[_.]/)
        invalid_filename if ehc.downcase != 'ehc' || suffix != 'csv'
        invalid_filename if date_string.to_i == 0 # ie, not all numbers
        @lga_name = lga_name_array.join("_")

        set_date(date_string)
      end

      def invalid_filename
        raise InvalidFilenameError.new(
          "'#{filename}' is not a valid filename, required format is 'ehc_lganame_YYYYMMDD.csv'"
        )
      end

    end
  end
end
