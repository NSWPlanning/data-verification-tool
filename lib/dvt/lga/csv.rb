module DVT
  module LGA
    class CSV < DVT::Base::Csv

      def record_class
        DVT::LGA::Record
      end

      def converters
        [Converters::WHITESPACE_STRIP,
         Converters::DP_PLAN_LABEL]
      end

    end
  end
end
