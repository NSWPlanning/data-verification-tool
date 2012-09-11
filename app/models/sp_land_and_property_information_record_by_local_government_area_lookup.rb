class SpLandAndPropertyInformationRecordByLocalGovernmentAreaLookup < Lookup

  attr_accessor :local_government_area

  # Returns a sparse Hash representation of all the records currently
  # in the database.  The structure is as follows:
  #
  #   {
  #     dp_plan_number => [active_record_id, md5sum, seen],
  #     dp_plan_number => [active_record_id, md5sum, seen],
  #     ...
  #   }
  def table
    unless local_government_area
      raise RuntimeError,
        'local_government_area must be set before calling SpLandAndPropertyInformationRecordByLocalGovernmentAreaLookup#table'
    end
    @table ||= Hash[target_class.connection.query("
      SELECT title_reference,id,md5sum
      FROM land_and_property_information_records
      WHERE local_government_area_id = %d
      AND plan_label LIKE 'SP%%'
    " % [local_government_area.id]).map {|r| [r[0], [r[1], r[2], false]]}]
  end

  def lookup_key_for(record)
    record.title_reference
  end

end
