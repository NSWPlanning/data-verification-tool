require 'digest/md5'
module DVT
  class BaseRecord

    attr_reader :row, :line

    def initialize(row, line)
      @row  = row
      @line = line
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
  end
end
