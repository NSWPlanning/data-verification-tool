require 'csv'
module LPI
  class CSV

    include Enumerable

    attr_reader :filename

    def initialize(filename)
      @filename = filename
    end

    def each
      ::CSV.foreach(filename, self.class.options) do |row|
        yield Record.new(row)
      end
    end

    def self.options
      {
        :headers => true, :col_sep => '|', :unconverted_fields => true,
        :converters => [
          Converters::CADID, Converters::DATETIME
        ]
      }
    end

  end
end
