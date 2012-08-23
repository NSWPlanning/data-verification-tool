module DVT
  class BaseDataFile

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
    def set_date(date_string)
      year,month,day = date_string[0..3],date_string[4..5],date_string[6..7]
      @date = Date.new(year.to_i,month.to_i,day.to_i)
    end
  end
end
