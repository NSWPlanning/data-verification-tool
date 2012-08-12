class LandAndPropertyInformationLookup

  class RecordAlreadySeenError < StandardError ; end

  attr_reader :target_class

  def initialize(target_class)
    @target_class = target_class
  end

  # Does this record already exist in the database?
  def has_record?(record)
    table.has_key?(record.cadastre_id.to_s)
  end

  def seen?(record)
    table[record.cadastre_id.to_s] && table[record.cadastre_id.to_s][2]
  end

  def mark_as_seen(record)
    raise RecordAlreadySeenError if seen?(record)
    if has_record?(record)
      table[record.cadastre_id.to_s][2] = true
    else
      add(record)
    end
  end
 
  # Is the record different from what is currently stored in the database?
  # Returns false if the record is unmodified, returns the appropriate
  # LandAndPropertyInformationRecord instance if it has changed.
  def find_if_changed(record)
    id, md5sum = id_and_md5sum_for(record)
    return false if md5sum == record.md5sum
    find(id)
  end

  def id_and_md5sum_for(record)
    table[record.cadastre_id.to_s]
  end

  def find(id)
    target_class.find(id)
  end

  def add(lpi)
    table[lpi.cadastre_id.to_s] = [lpi.id.to_s, lpi.md5sum, true]
  end

  # Returns a sparse Hash representation of all the records currently
  # in the database.  The structure is as follows:
  #
  #   {
  #     cadastre_id => [active_record_id, md5sum, seen],
  #     cadastre_id => [active_record_id, md5sum, seen],
  #     ...
  #   }
  protected
  def table
    @table ||= Hash[target_class.connection.query('
      SELECT cadastre_id,id,md5sum
      FROM land_and_property_information_records
    ').map {|r| [r[0], [r[1], r[2], false]]}]
  end
end
