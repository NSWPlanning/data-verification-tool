module DVT
  module NSI
    class DataFile < DVT::Base::DataFile

      attr_reader :lga_name

      def initialize(filename, local_government_area_record_name)
        @lga_name = local_government_area_record_name
        super(filename)
      end

      def csv_class
        DVT::NSI::CSV
      end

      protected

      def expected_headers
        [
          "Date_of_update",
          "Council_ID",
          "LEP_NSI_zone",
          "LEP_SI_zone",
          "LEP_name"
        ]
      end

      def parse_filename(filename)
        @filename = filename
        @lga_name, date_string = self.class.parse_filename(filename)
        set_date(date_string)
      end

      public

      def self.parse_filename(filename)
        basename = File.basename(filename)

        ehc, *lga_name_array, is_nsi, date_string, suffix = basename.split(/[_.]/)

        if (ehc.downcase != 'ehc' || is_nsi.downcase != 'lep' || suffix != 'csv') ||
           (date_string.to_i == 0)
          invalid_filename(filename)
        end

        lga_name = lga_name_array.join("_")
        return lga_name, date_string
      end

      protected

      def self.invalid_filename filename
        raise InvalidFilenameError.new(
          "'#{filename}' is not a valid filename, required format is 'ehc_lganame_lep_YYYYMMDD.csv'"
        )
      end

    end
  end
end
