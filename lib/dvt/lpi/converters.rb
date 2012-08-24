module DVT
  module LPI
    class Converters

      CADID = lambda do |field, field_info|
        return field unless field_info.header == 'CADID'
        Integer(field)
      end

    end
  end
end
