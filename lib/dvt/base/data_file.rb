module DVT
  module Base
    class DataFile

      class InvalidFilenameError < StandardError; end

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
        @csv ||= csv_class.new(filename)
      end

      def expected_headers
        []
      end

      def optional_headers
        []
      end

      def header_difference
        received_headers_map = array_map(csv.headers)
        expected_headers_map = array_map(expected_headers)
        optional_headers_map = array_map(optional_headers)
        {}.tap do |result|
          expected_headers = expected_headers_map.keys
          received_headers_map.each_pair do |key, value|
            if expected_headers_map.has_key? key
              expected_headers.delete key
              expected = expected_headers_map[key]
              if (expected.casecmp(value) != 0)                
                # error expected, got
                result[key] = "\'#{value}\' should be \'#{expected}\'"
              end
            elsif optional_headers_map.has_key? key
              expected = optional_headers_map[key]
              if (expected.casecmp(value) != 0)
                # error expected, got
                result[key] = "\'#{value}\' should be \'#{expected}\'"
              end
            else
              # error should not be present
              result[key] = "\'#{value}\' should not be present"
            end
          end

          expected_headers.each do |key, value|
            result[key] = "'#{expected_headers_map[key]}' is missing"
          end
        end

      end

      protected

      def set_date(date_string)
        year,month,day = date_string[0..3],date_string[4..5],date_string[6..7]
        @date = Date.new(year.to_i,month.to_i,day.to_i)
      end

      private

      def array_map(array)
        unless array.blank?
          Hash[array.map { |k| [k.downcase.to_sym, k] }]
        else
          {}
        end
      end

    end
  end
end
