require 'date'
module DVT
  module LPI
    class DataFile < DVT::Base::DataFile

      def csv_class
        DVT::LPI::CSV
      end

      protected
      def parse_filename(filename)
        @filename = filename
        basename = File.basename(filename)
        ehc,lpma,date_string,suffix = basename.split(/[_.]/)
        invalid_filename if ehc != 'EHC' || lpma != 'LPMA' || suffix != 'csv'
        set_date(date_string)
      end

      protected
      def invalid_filename
        raise ArgumentError.new(
          "'#{filename}' is not a valid filename, required format is 'EHC_LPMA_YYYYMMDD.csv'"
        )
      end

    end
  end
end
