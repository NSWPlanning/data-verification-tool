require 'dvt/record_field'
module DVT
  module LPI
    class Record < BaseRecord

      has_field 'CADID',          :aliases => [:cadastre_id]
      has_field 'LOTNUMBER',      :aliases => [:lot_number]
      has_field 'SECTIONNUMBER',  :aliases => [:section_number]
      has_field 'PLANLABEL',      :aliases => [:plan_label]
      # NOTE - This is called title_reference in the DB
      has_field 'STD_DP_LOT_ID',  :aliases => [:title_reference]
      has_field 'STARTDATE',      :aliases => [:start_date]
      has_field 'ENDDATE',        :aliases => [:end_date]
      has_field 'MODIFIEDDATE',   :aliases => [:modified_date]
      has_field 'LASTUPDATE',     :aliases => [:last_update]
      has_field 'LGANAME',        :aliases => [:lga_name]

      # Extra attributes that are not included in the CSV data, but are relevant
      # to the records
      def self.extra_attributes
        [:md5sum]
      end

    end
  end
end
