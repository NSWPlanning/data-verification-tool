require 'date'
module LPI
  class DataFile

    include Enumerable

    attr_reader :filename, :date

    def initialize(filename)
      parse_filename(filename)
    end

    def each
      csv.each do |record|
        yield record
      end
    end

    def csv
      @csv ||= LPI::CSV.new(filename)
    end

    protected
    def parse_filename(filename)
      @filename = filename
      basename = File.basename(filename)
      ehc,lpma,date_string,suffix = basename.split(/[_.]/)
      invalid_filename if ehc != 'EHC' || lpma != 'LPMA' || suffix != 'csv'
      set_date(date_string)
    end

    protected
    def invalid_filename
      raise ArgumentError.new(
        "'#{filename}' is not a valid filename, required format is 'EHC_LPMA_YYYYMMDD.csv'"
      )
    end

    protected
    def set_date(date_string)
      year,month,day = date_string[0..3],date_string[4..5],date_string[6..7]
      @date = Date.new(year.to_i,month.to_i,day.to_i)
    end

  end
end
