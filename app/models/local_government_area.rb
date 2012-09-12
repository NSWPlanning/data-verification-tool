class LocalGovernmentArea < ActiveRecord::Base
  has_paper_trail
  validates_uniqueness_of :name
  validates_presence_of :name
  attr_accessible :name, :alias
  attr_accessible :name, :alias, :user_ids, :as => :admin

  has_and_belongs_to_many :users
  has_many :land_and_property_information_records
  has_many :local_government_area_records do
    def invalid_count
      invalid.count
    end
    def valid_count
      valid.count
    end
  end

  default_scope order(:name)

  def to_s
    name
  end

  def find_land_and_property_information_record_by_title_reference(title_reference)
    land_and_property_information_records.find_by_title_reference(title_reference)
  end

  def delete_invalid_local_government_area_records
    local_government_area_records.invalid.delete_all
  end

  def invalid_record_count
    local_government_area_records.invalid_count
  end

  def valid_record_count
    local_government_area_records.valid_count
  end

  # Returns a list of all of the duplicate DP records for an LGA as an
  # array of arrays:
  #
  #   # 1//DP1234 appears 5 times, 2//DP6789 appears 10 times for the LGA
  #   [
  #     ['1//DP1234', '5'],
  #     ['2//DP6789', '10'],
  #   ]
  def duplicate_dp_records
    connection.query(%{
      SELECT
        CONCAT(dp_lot_number, '/', dp_section_number, '/', dp_plan_number), 
        COUNT(dp_plan_number) AS duplicate_count
      FROM local_government_area_records
      WHERE dp_plan_number LIKE 'DP%%' AND local_government_area_id = %d
      GROUP BY dp_lot_number, dp_section_number, dp_plan_number
      HAVING (COUNT(dp_plan_number) > 1)
    } % [id])
  end

  def mark_duplicate_dp_records_invalid
    connection.query(%{
      UPDATE local_government_area_records
      SET is_valid = FALSE
      WHERE id in (
        SELECT id FROM (
          SELECT
            id,
            count(*) OVER (
              PARTITION BY dp_plan_number, dp_section_number, dp_lot_number
            ) AS dup_count
          FROM local_government_area_records
          WHERE dp_plan_number LIKE 'DP%%' AND local_government_area_id = %d
        ) AS dup_id
        WHERE dup_id.dup_count > 1
      )
    } % [id])
  end

  def mark_inconsistent_sp_records_invalid
    connection.query(
      %{
        UPDATE local_government_area_records SET is_valid = false
        WHERE dp_plan_number IN (%s)
        AND local_government_area_id = %d
      } % [inconsistent_sp_records_query, id]
    )
    return inconsistent_sp_records
  end

  def inconsistent_sp_records
    connection.query(inconsistent_sp_records_query).flatten
  end

  def inconsistent_sp_records_query
    %{
      SELECT dp_plan_number
      FROM (
        SELECT DISTINCT ON (dp_plan_number, %s) dp_plan_number
        FROM local_government_area_records
        WHERE local_government_area_id = %d
        AND dp_plan_number LIKE 'SP%%'
      ) AS duplicates
      GROUP BY dp_plan_number
      HAVING COUNT(*) > 1
    } % [inconsistent_attributes_comparison_fields.join(','), id]
  end

  def inconsistent_attributes_comparison_fields
    LocalGovernmentAreaRecord.inconsistent_attributes_comparison_fields
  end

  # Returns an array of all of the DP LPI record title references for this LGA
  # for which there is no corresponging LGA record.
  def missing_dp_lpi_records
    # FIXME - The CONCAT() functions in this query are to ensure that NULL
    # values get coerced into empty strings.  In the import CSV, the value
    # |""| is recorded as "", whereas || is recorded as NULL, and sometimes
    # one is present in the LGA import and another in the LPI import.
    connection.query(%{
      SELECT title_reference
      FROM land_and_property_information_records AS lpi_records
      LEFT JOIN local_government_area_records AS lga_records
        ON lga_records.local_government_area_id = lpi_records.local_government_area_id
        AND lga_records.dp_plan_number = lpi_records.plan_label
        AND CONCAT('', lga_records.dp_section_number) = CONCAT('', lpi_records.section_number)
        AND CONCAT('', lga_records.dp_lot_number) = CONCAT('', lpi_records.lot_number)
      WHERE lpi_records.plan_label LIKE 'DP%%'
      AND lga_records.dp_plan_number IS NULL
      AND lpi_records.local_government_area_id = %d
    } % [id]).flatten
  end

  def missing_sp_lpi_records
    connection.query(%{
      SELECT title_reference
      FROM land_and_property_information_records AS lpi_records
      LEFT JOIN local_government_area_records AS lga_records
        ON lga_records.local_government_area_id = lpi_records.local_government_area_id
        AND lga_records.dp_plan_number = lpi_records.plan_label
      WHERE lpi_records.plan_label LIKE 'SP%%'
      AND lga_records.dp_plan_number IS NULL
      AND lpi_records.local_government_area_id = %d
    } % [id]).flatten
  end

end
