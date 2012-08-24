module DVT
  module LGA
    class CSV < BaseCsv

      def record_class
        DVT::LGA::Record
      end

    end
  end
end
