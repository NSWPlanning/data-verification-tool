module DVT
  module LPI
    class CSV < DVT::Base::Csv

      def record_class
        DVT::LPI::Record
      end

      def converters
        [Converters::CADID]
      end

    end
  end
end
