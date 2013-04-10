class LocalGovernmentAreaLookup

  class AliasNotFoundError < StandardError ; end

  # Find a LocalGovernmentArea id from its alias.  The lga_name is the value
  # that is found in the LPI CSV import file under the LGANAME header.  The
  # id is the ActiveRecord id of the corresponding LocalGovernmentArea id.
  #
  # If the LGA is not found, an AliasNotFoundError is raised.
  def find_id_from_lpi_alias(lga_name)
    if lpi_table.has_key?(lga_name)
      return lpi_table[lga_name]
    else
      raise AliasNotFoundError, "Unable to find LGA '#{lga_name}'"
    end
  end

  def find_id_from_filename_alias(filename_alias)
    lookup_alias = filename_alias.upcase
    if filename_table.has_key?(lookup_alias)
      return filename_table[lookup_alias]
    else
      raise AliasNotFoundError, "Unable to find LGA for '#{filename_alias}'"
    end  
  end

  protected
  def lpi_table
    @lpi_table ||= generate_lpi_table
  end

  def filename_table
    @filename_table ||= generate_filename_table
  end

  protected
  def generate_lpi_table
    Hash[target_class.connection.query("
      SELECT 
        CASE WHEN lpi_alias = '' THEN UPPER(name) 
             WHEN lpi_alias IS NULL THEN UPPER(name) 
             ELSE lpi_alias 
        END, 
        id
      FROM local_government_areas
    ").map {|r| [r[0], r[1]]}]
  end

  def generate_filename_table
    Hash[target_class.connection.query("
      SELECT 
        CASE WHEN filename_alias = '' THEN UPPER(name) 
             WHEN filename_alias IS NULL THEN UPPER(name) 
             ELSE filename_alias 
        END, 
        id
      FROM local_government_areas
    ").map {|r| [r[0], r[1]]}]
  end

  protected
  def target_class
    LocalGovernmentArea
  end

end
