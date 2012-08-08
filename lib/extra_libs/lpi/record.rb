require 'digest/md5'
module LPI
  class Record

    attr_reader :row

    def self.header_fields
      required_fields
    end

    def self.required_fields
      [
        'CADID', 'LOTNUMBER', 'SECTIONNUMBER', 'PLANLABEL', 'STD_DP_LOT_ID',
        'STARTDATE', 'ENDDATE', 'MODIFIEDDATE', 'LASTUPDATE', 'LGANAME'
      ]
    end

    header_fields.each do |field|
      define_method field.downcase do
        row[field]
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

  end
end
