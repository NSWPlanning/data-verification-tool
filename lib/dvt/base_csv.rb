require 'csv'
module DVT
  class BaseCsv

    include Enumerable

    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def each
      # CSV.foreach has no way to track the line number, so track it internally
      line = 1
      ::CSV.foreach(filename, options) do |row|
        line += 1
        yield record_class.new(row, line)
      end
    end

    def options
      { :headers => true, :col_sep => '|', :skip_blanks => true,
        :converters => converters }
    end

    def converters
      []
    end

  end

end
