module LPI
  class Converters

    CADID = lambda do |field, field_info|
      return field unless field_info.header == 'CADID'
      Integer(field)
    end

    DATETIME = lambda do |field, field_info|
      return field unless Record.datetime_fields.include?(field_info.header)
      DateTime.parse(field)
    end

  end
end
