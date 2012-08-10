require 'digest/md5'
require 'extra_libs/lpi/field'
module LPI
  class Record

    attr_reader :row

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

    def self.header_fields
      required_fields
    end

    def self.required_fields
      fields.map(&:name)
    end

    def self.aliases_for(field)
      fields.find {|f| f.name == field}.aliases
    end

    def self.attributes
      fields.map(&:to_attribute) + extra_attributes
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

    def initialize(row)
      @row = row
    end

    # Returns a checksum for this record, based on the CSV line content.
    # Note that the checksum includes the trailing EOL character from the
    # CSV record.
    def md5sum
      @md5sum ||= Digest::MD5.hexdigest(row.to_csv)
    end

    def valid?
      has_required_fields?
    end

    def has_required_fields?
      self.class.required_fields.all? do |field|
        row.include? field
      end
    end

    # Convert this object to a Hash.  For each field on the object, if
    # aliases are present, the first alias in the array is used as the hash
    # key.  Otherwise the downcased CSV field name is used.
    def to_hash
      Hash[self.class.attributes.map {|attr| [attr, send(attr)]}]
    end

  end
end
