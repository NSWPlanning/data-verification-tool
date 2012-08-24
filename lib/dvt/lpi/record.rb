require 'dvt/lpi/field'
module DVT
  module LPI
    class Record < BaseRecord

      def self.fields
        @fields ||= [
          Field.new('CADID',          :aliases => [:cadastre_id]),
          Field.new('LOTNUMBER',      :aliases => [:lot_number]),
          Field.new('SECTIONNUMBER',  :aliases => [:section_number]),
          Field.new('PLANLABEL',      :aliases => [:plan_label]),
          Field.new('STD_DP_LOT_ID',  :aliases => [:title_reference]),
          Field.new('STARTDATE',      :aliases => [:start_date]),
          Field.new('ENDDATE',        :aliases => [:end_date]),
          Field.new('MODIFIEDDATE',   :aliases => [:modified_date]),
          Field.new('LASTUPDATE',     :aliases => [:last_update]),
          Field.new('LGANAME',        :aliases => [:lga_name])
        ]
      end


      # Extra attributes that are not included in the CSV data, but are relevant
      # to the records
      def self.extra_attributes
        [:md5sum]
      end

      header_fields.each do |field|
        method_name = field.downcase
        define_method method_name do
          row[field]
        end
        aliases_for(field).each do |field_alias|
          alias_method field_alias, method_name
        end
      end

    end
  end
end
