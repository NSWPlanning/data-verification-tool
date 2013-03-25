module DVT
  module Base
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
        @csv ||= csv_class.new(filename)
      end

      def expected_headers
        []
      end

      def header_difference
        received_headers =  csv.headers
        zipped_headers = expected_headers.zip received_headers

        {}.tap do |result|
          missing_field = false
          zipped_headers.each_with_index do |headers, index|

            # Unless they're the same thing, then something is wrong
            unless headers.uniq.length == 1 || missing_field == true
              expected, got = headers

              if got.blank?
                message = "'#{expected}' is missing"

              elsif expected.downcase == got.downcase
                message = "\'#{got}\' should be \'#{expected}\'"

              elsif !expected_headers.collect(&:downcase).include?(got.downcase)
                message = "\'#{got}\' should not be present"

              elsif (index != expected_headers.length - 1) &&
                    (got == expected_headers[index+1])

                message = "'#{expected}' is missing"
                missing_field = true

              else
                message = "\'#{got}\' should be swapped with \'#{expected}\'"
              end

              result[:column_errors] ||= {}
              result[:column_errors].merge!({
                index => {
                  :expected => expected,
                  :got => got,
                  :message => message
                }
              })
            end

          end
        end
      end

      protected

      def set_date(date_string)
        year,month,day = date_string[0..3],date_string[4..5],date_string[6..7]
        @date = Date.new(year.to_i,month.to_i,day.to_i)
      end
    end
  end
end
