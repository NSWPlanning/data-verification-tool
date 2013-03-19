module DVT
  module NSI
    class CSV < DVT::Base::Csv

      def record_class
        DVT::NSI::Record
      end

    end
  end
end
