class LocalGovernmentAreaRecordLookup < Lookup

  attr_accessor :local_government_area

  # Returns a sparse Hash representation of all the records currently
  # in the database.  Note that this is scoped to the local_government_area,
  # which must be set before calling this method.
  #
  # The structure is as follows:
  #
  #   {
  #     council_id => [active_record_id, md5sum, seen],
  #     council_id => [active_record_id, md5sum, seen],
  #     ...
  #   }
  protected
  def table

    unless local_government_area
      raise RuntimeError,
        'local_government_area must be set before calling LocalGovernmentAreaRecordLookup#table'
    end

    @table ||= Hash[target_class.connection.query(
      table_query
    ).map {|r| [r[0], [r[1], r[2], false]]}]
  end

  protected
  def table_query
    %{
      SELECT council_id,id,md5sum
      FROM local_government_area_records
      WHERE local_government_area_id = %d
    } % local_government_area.id.to_i
  end

  protected
  def lookup_key_for(record)
    # Ensure that actual nil is returned, rather than nil.to_s
    return nil if record.council_id.nil?
    record.council_id.to_s
  end

end
