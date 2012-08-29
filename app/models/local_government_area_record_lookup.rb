class LocalGovernmentAreaRecordLookup < Lookup

  protected
  def table
    {}
  end

  protected
  def lookup_key_for(record)
    "foo"
  end
end
