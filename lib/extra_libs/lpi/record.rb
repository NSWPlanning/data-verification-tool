module LPI
  class Record

    attr_reader :row

    def self.header_fields
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

  end
end
