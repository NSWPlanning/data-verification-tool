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
        ehc,@lga_name,date_string,suffix = basename.split(/[_.]/)
        invalid_filename if ehc.downcase != 'ehc' || suffix != 'csv'
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
