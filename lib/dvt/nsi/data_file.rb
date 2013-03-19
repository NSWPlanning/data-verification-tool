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

      def parse_filename(filename)
        @filename = filename
        basename = File.basename(filename)

        ehc, *lga_name_array, is_nsi, date_string, suffix = basename.split(/[_.]/)

        if (ehc.downcase != 'ehc' || is_nsi.downcase != 'lep' || suffix != 'csv') ||
           (date_string.to_i == 0)
          invalid_filename
        end

        @lga_name = lga_name_array.join("_")
        set_date(date_string)
      end

      def invalid_filename
        raise ArgumentError.new(
          "'#{filename}' is not a valid filename, required format is 'ehc_lganame_lep_YYYYMMDD.csv'"
        )
      end

    end
  end
end
