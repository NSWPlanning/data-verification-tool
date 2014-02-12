module DVT
  module LGA
    module Converters
      WHITESPACE_STRIP = lambda do |field, field_info|
        field.respond_to?(:strip) ? field.strip : field
      end

      # Strip internal space from plan label. That is, turn "DP 1234" into "DP1234"
      DP_PLAN_LABEL = lambda do |field, field_info|
        return field unless !field_info.header.nil? && field_info.header.casecmp('DP_plan_number') == 0
        field.gsub(" ", "")
      end
    end
  end
end
