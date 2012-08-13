require 'csv'
module LPI
  class CSV

    include Enumerable

    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def each
      # CSV.foreach has no way to track the line number, so track it internally
      line = 1
      ::CSV.foreach(filename, self.class.options) do |row|
        line += 1
        yield LPI::Record.new(row, line)
      end
    end

    def self.options
      {
        :headers => true, :col_sep => '|', :converters => [
          Converters::CADID
        ]
      }
    end

  end
end
