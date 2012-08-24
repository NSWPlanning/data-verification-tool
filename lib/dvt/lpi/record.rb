require 'dvt/record_field'
module DVT
  module LPI
    class Record < BaseRecord

      def self.fields
        @fields ||= [
          RecordField.new('CADID',          :aliases => [:cadastre_id]),
          RecordField.new('LOTNUMBER',      :aliases => [:lot_number]),
          RecordField.new('SECTIONNUMBER',  :aliases => [:section_number]),
          RecordField.new('PLANLABEL',      :aliases => [:plan_label]),
          RecordField.new('STD_DP_LOT_ID',  :aliases => [:title_reference]),
          RecordField.new('STARTDATE',      :aliases => [:start_date]),
          RecordField.new('ENDDATE',        :aliases => [:end_date]),
          RecordField.new('MODIFIEDDATE',   :aliases => [:modified_date]),
          RecordField.new('LASTUPDATE',     :aliases => [:last_update]),
          RecordField.new('LGANAME',        :aliases => [:lga_name])
        ]
      end


      # Extra attributes that are not included in the CSV data, but are relevant
      # to the records
      def self.extra_attributes
        [:md5sum]
      end

      # FIXME - DRY
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
