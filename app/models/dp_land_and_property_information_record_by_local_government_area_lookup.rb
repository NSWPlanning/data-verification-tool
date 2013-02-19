class DpLandAndPropertyInformationRecordByLocalGovernmentAreaLookup < Lookup

  attr_accessor :local_government_area

  # Returns a sparse Hash representation of all the records currently
  # in the database.  The structure is as follows:
  #
  #   {
  #     [lot_number,section_number,plan_label] => [active_record_id, md5sum, seen],
  #     [lot_number,section_number,plan_label] => [active_record_id, md5sum, seen],
  #     ...
  #   }
  def table
    unless local_government_area
      raise RuntimeError,
        'local_government_area must be set before calling DpLandAndPropertyInformationRecordByLocalGovernmentAreaLookup#table'
    end
    @table ||= Hash[target_class.connection.query("
      SELECT
        CONCAT('',lot_number),
        CONCAT('',section_number),
        CONCAT('',plan_label),
        id,
        md5sum
      FROM land_and_property_information_records
      WHERE local_government_area_id = %d
      AND plan_label LIKE 'DP%%'
    " % [local_government_area.id]).map {|r| [[r[0],r[1],r[2]], [r[3], r[4], false]]}]
  end

  def lookup_key_for(record)
    [record.dp_lot_number.to_s, record.dp_section_number.to_s, record.dp_plan_number.to_s]
  end

end
