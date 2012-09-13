class InvalidRecords
  include ImportStatisticsSet
  requires_attributes :malformed, :invalid_title_reference,
      :duplicate_title_reference, :invalid_address, :missing_si_zone,
      :inconsistent_attributes, :total
end
