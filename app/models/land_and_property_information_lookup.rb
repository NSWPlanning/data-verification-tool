class LandAndPropertyInformationLookup

  class RecordAlreadySeenError < StandardError
    def initialize(record)
      super(
        "Cadastre id #{record.cadastre_id} already seen (line #{record.line})"
      )
    end
  end

  attr_reader :target_class

  def initialize(target_class)
    @target_class = target_class
  end

  # Does this record already exist in the database?
  def has_record?(record)
    table.has_key?(lookup_key_for(record))
  end

  # Raises a RecordAlreadySeenError if the record has been seen already,
  # otherwise returns nil
  def seen!(record)
    if seen?(record)
      raise RecordAlreadySeenError.new(record)
    end
  end

  def seen?(record)
    table[lookup_key_for(record)] && table[lookup_key_for(record)][2]
  end

  def mark_as_seen(record)
    raise RecordAlreadySeenError if seen?(record)
    if has_record?(record)
      table[lookup_key_for(record)][2] = true
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
    table[lookup_key_for(record)]
  end

  def find(id)
    target_class.find(id)
  end

  def add(lpi)
    id = lpi.respond_to?(:id) ? lpi.id.to_s : nil
    table[lookup_key_for(lpi)] = [id, lpi.md5sum, true]
  end

  # Returns the subject of the #table hash that is have not been marked as seen.
  def unseen
    table.reject do |k, v|
      v[2]
    end
  end

  def unseen_ids
    unseen.map do |k,v|
      v[0]
    end
  end

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

  protected
  def lookup_key_for(record)
    [record.cadastre_id.to_s, record.lga_name]
  end

end
