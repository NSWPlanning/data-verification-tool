require 'csv'
module DVT
  module Base
    class Csv

      include Enumerable

      attr_reader :filename

      def initialize(filename)
        @filename = filename
      end

      def headers
        csv = ::CSV.open(filename, {:col_sep => '|', :converters => header_converters})
        # we use :converters above, as csv.shift() below doesn't treat the first row
        # separately as a header. So, we use the header_converters on a normal row to
        # mimic the way they will work when a file is being processed.
        headers = csv.shift()
        csv.close()
        headers
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
        {
          :headers => true,
          :col_sep => '|',
          :skip_blanks => true,
          :header_converters => header_converters,
          :converters => converters
        }
      end

      def converters
        []
      end

      def header_converters
        []
      end

    end

  end

end
