module LPI
  class DataFile

    include Enumerable

    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def each
      csv.each do |record|
        yield record
      end
    end

    def csv
      @csv ||= LPI::CSV.new(filename)
    end

  end
end
