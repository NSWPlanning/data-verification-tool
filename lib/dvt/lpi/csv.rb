module DVT
  module LPI
    class CSV < BaseCsv

      def record_class
        DVT::LPI::Record
      end

      def converters
        [Converters::CADID]
      end

    end
  end
end
