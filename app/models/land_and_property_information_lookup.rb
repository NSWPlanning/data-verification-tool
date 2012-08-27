class LandAndPropertyInformationLookup < Lookup

  # Returns a sparse Hash representation of all the records currently
  # in the database.  The structure is as follows:
  #
  #   {
  #     [cadastre_id, lga_alias] => [active_record_id, md5sum, seen],
  #     [cadastre_id, lga_alias] => [active_record_id, md5sum, seen],
  #     ...
  #   }
  protected
  def table
    @table ||= Hash[target_class.connection.query('
      SELECT cadastre_id,lga_name,id,md5sum
      FROM land_and_property_information_records
    ').map {|r| [[r[0], r[1]], [r[2], r[3], false]]}]
  end

  # LPI records are uniquely identified by a combination of the LGANAME
  # and CADID fields from the import file.
  protected
  def lookup_key_for(record)
    [record.cadastre_id.to_s, record.lga_name]
  end

end
