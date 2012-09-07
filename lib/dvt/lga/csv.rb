module DVT
  module LGA
    class CSV < BaseCsv

      def record_class
        DVT::LGA::Record
      end

      def converters
        [Converters::WHITESPACE_STRIP]
      end

    end
  end
end
