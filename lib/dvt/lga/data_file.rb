module DVT
  module LGA
    class DataFile < DVT::Base::DataFile

      attr_reader :lga_name

      def csv_class
        DVT::LGA::CSV
      end

      protected
      def parse_filename(filename)
        @filename = filename
        basename = File.basename(filename)
        ehc,*lga_name_array,date_string,suffix = basename.split(/[_.]/)
        invalid_filename if ehc.downcase != 'ehc' || suffix != 'csv'
        invalid_filename if date_string.to_i == 0 # ie, not all numbers
        @lga_name = lga_name_array.join("_")
        set_date(date_string)
      end

      protected
      def invalid_filename
        raise ArgumentError.new(
          "'#{filename}' is not a valid filename, required format is 'ehc_lganame_YYYYMMDD.csv'"
        )
      end
    end
  end
end
