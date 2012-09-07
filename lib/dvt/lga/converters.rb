module DVT
  module LGA
    module Converters
      WHITESPACE_STRIP = lambda do |field, field_info|
        field.respond_to?(:strip) ? field.strip : field
      end
    end
  end
end
