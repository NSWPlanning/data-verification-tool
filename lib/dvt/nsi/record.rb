require 'dvt/record_field'

module DVT
  module NSI
    class Record < DVT::Base::Record

      has_field "Date_of_update"

      has_field "Council_ID", :required => true

      has_field "LEP_NSI_zone", :required => false

      has_field "LEP_SI_zone", :required => true

      has_field "LEP_name", :required => true

      def self.extra_attributes
        [:md5sum]
      end

      def to_checksum_string
        stripped_row = row.dup
        stripped_row.delete('Date_of_update')
        stripped_row.to_csv
      end

    end
  end
end
