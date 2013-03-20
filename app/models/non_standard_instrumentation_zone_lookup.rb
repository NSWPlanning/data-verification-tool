class NonStandardInstrumentationZoneLookup < Lookup

  attr_accessor :local_government_area

  protected

  # Returns a sparse Hash representation of all the records currently
  # in the database.  The structure is as follows:
  #
  #   {
  #     [council_id, lep_nsi_zone, lep_si_zone] => [active_record_id, seen],
  #     [council_id, lep_nsi_zone, lep_si_zone] => [active_record_id, seen],
  #     ...
  #   }
  def table
    unless local_government_area
      raise RuntimeError, 'local_government_area must be set before calling NonStandardInstrumentationZoneLookup#table'
    end

    raw_query = table_query
    query = target_class.connection.query(raw_query)

    @table ||= Hash[query.map { |r|
      [ [r[0], r[1], r[2]], [r[3], false] ]
    }]

  end

  def table_query
    %{
      SELECT council_id, lep_nsi_zone, lep_si_zone, id, md5sum
      FROM non_standard_instrumentation_zones
      WHERE local_government_area_id = %d
    } % local_government_area.id.to_i
  end

  def lookup_key_for(record)
    [
      record.council_id.to_s,
      record.lep_nsi_zone,
      record.lep_si_zone
    ]
  end

end
