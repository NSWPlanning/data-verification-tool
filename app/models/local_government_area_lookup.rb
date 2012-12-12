class LocalGovernmentAreaLookup

  class AliasNotFoundError < StandardError ; end

  # Find a LocalGovernmentArea id from its alias.  The lga_name is the value
  # that is found in the LPI CSV import file under the LGANAME header.  The
  # id is the ActiveRecord id of the corresponding LocalGovernmentArea id.
  #
  # If the LGA is not found, an AliasNotFoundError is raised.
  def find_id_from_lpi_alias(lga_name)
    if table.has_key?(lga_name)
      return table[lga_name]
    else
      raise AliasNotFoundError, "Unable to find LGA '#{lga_name}'"
    end
  end

  protected
  def table
    @table ||= generate_table
  end

  protected
  def generate_table
    Hash[target_class.connection.query("
      SELECT 
        CASE WHEN lpi_alias = '' THEN UPPER(name) ELSE lpi_alias END, id
      FROM local_government_areas
    ").map {|r| [r[0], r[1]]}]
  end

  protected
  def target_class
    LocalGovernmentArea
  end

end
