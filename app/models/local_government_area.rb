class LocalGovernmentArea < ActiveRecord::Base

  has_paper_trail
  validates_uniqueness_of :name
  validates_presence_of :name
  attr_accessible :name, :alias
  attr_accessible :name, :alias, :user_ids, :as => :admin

  has_and_belongs_to_many :users
  has_many :land_and_property_information_records
  has_many :local_government_area_record_import_logs
  has_many :local_government_area_records do
    def invalid_count
      invalid.count
    end
    def valid_count
      valid.count
    end
    def in_council_and_lpi
      where('land_and_property_information_record_id IS NOT NULL')
    end
    def only_in_council
      where('land_and_property_information_record_id IS NULL')
    end
  end

  delegate :most_recent_import_date,
    :to => :local_government_area_record_import_logs

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
  def missing_dp_lpi_records_count
    connection.query(%{
      SELECT COUNT(title_reference)
      FROM land_and_property_information_records AS lpi_records
      LEFT JOIN local_government_area_records AS lga_records
        ON lga_records.local_government_area_id = lpi_records.local_government_area_id
        AND lga_records.dp_plan_number = lpi_records.plan_label
        AND CONCAT('', lga_records.dp_section_number) = CONCAT('', lpi_records.section_number)
        AND CONCAT('', lga_records.dp_lot_number) = CONCAT('', lpi_records.lot_number)
      WHERE lpi_records.plan_label LIKE 'DP%%'
      AND lga_records.dp_plan_number IS NULL
      AND lpi_records.local_government_area_id = %d
    } % [id])[0][0].to_i
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
  def missing_sp_lpi_records_count
    connection.query(%{
      SELECT COUNT(DISTINCT plan_label)
      FROM land_and_property_information_records AS lpi_records
      LEFT JOIN local_government_area_records AS lga_records
        ON lga_records.local_government_area_id = lpi_records.local_government_area_id
        AND lga_records.dp_plan_number = lpi_records.plan_label
        AND lga_records.dp_section_number = lpi_records.section_number
        AND lga_records.dp_lot_number = lpi_records.lot_number
      WHERE lpi_records.plan_label LIKE 'SP%%'
      AND lga_records.dp_plan_number IS NULL
      AND lpi_records.local_government_area_id = %d
    } % [id])[0][0].to_i
  end

  def self.statistics_set_names
    [
      :data_quality, :council_file_statistics, :invalid_records,
      :land_parcel_statistics, :lpi_comparison
    ]
  end

  def data_quality
    @data_quality ||= DataQuality.new(
      {
        :in_council_and_lpi => in_council_and_lpi.count,
        :only_in_lpi        => only_in_lpi.count,
        :only_in_council    => only_in_council.count
      }
    )
  end

  def council_file_statistics
    @council_file_statistics ||= CouncilFileStatistics.new(
      {
        :dp_records => local_government_area_records.dp.count,
        :sp_records => local_government_area_records.sp.count,
        :malformed_records => local_government_area_records.not_sp_or_dp.count
      }
    )
  end

  def invalid_records
    # TODO
    @invalid_records ||= InvalidRecords.new(
      :malformed => 0,
      :invalid_title_reference => 0,
      :duplicate_title_reference => 0,
      :invalid_address => 0,
      :missing_si_zone => 0,
      :inconsistent_attributes => 0,
      :total => 0
    )
  end

  def land_parcel_statistics
    @land_parcel_statistics ||= LandParcelStatistics.new(
      :council_unique_dp => council_unique_dp_count,
      :council_unique_parent_sp => council_unique_parent_sp_count,
      :lpi_unique_dp => lpi_unique_dp_count,
      :lpi_unique_parent_sp => lpi_unique_parent_sp_count
    )
  end

  def lpi_comparison
    # TODO
    @lpi_comparison ||= LpiComparison.new(
      :in_both_dp => in_both_dp_count,
      :in_both_parent_sp => in_both_parent_sp_count,
      :only_in_council_dp => only_in_council_dp_count,
      :only_in_council_parent_sp => only_in_council_parent_sp_count,
      :only_in_lpi_dp => only_in_lpi_dp_count,
      :only_in_lpi_parent_sp => only_in_lpi_parent_sp_count,
      :in_retired_lpi_dp => in_retired_lpi_dp_count,
      :in_retired_lpi_parent_sp => in_retired_lpi_parent_sp_count
    )
  end

  def has_import?
    local_government_area_record_import_logs.present?
  end

  def in_council_and_lpi
    local_government_area_records.in_council_and_lpi
  end

  def only_in_council
    local_government_area_records.only_in_council
  end

  def only_in_lpi
    missing_sp_lpi_records + missing_dp_lpi_records
  end

  def council_unique_dp_count
    connection.query(%{
      SELECT COUNT(DISTINCT(dp_lot_number, dp_section_number, dp_plan_number))
      FROM local_government_area_records
      WHERE local_government_area_id = %d
        AND dp_plan_number LIKE 'DP%%'
    } % [id])[0][0].to_i
  end

  def council_unique_parent_sp_count
    connection.query(%{
      SELECT COUNT(DISTINCT(dp_plan_number))
      FROM local_government_area_records
      WHERE local_government_area_id = %d
        AND dp_plan_number LIKE 'SP%%'
    } % [id])[0][0].to_i
  end

  def lpi_unique_dp_count
    connection.query(%{
      SELECT COUNT(DISTINCT(title_reference))
      FROM land_and_property_information_records
      WHERE local_government_area_id = %d
        AND plan_label LIKE 'DP%%'
    } % [id])[0][0].to_i
  end

  def lpi_unique_parent_sp_count
    connection.query(%{
      SELECT COUNT(DISTINCT(title_reference))
      FROM land_and_property_information_records
      WHERE local_government_area_id = %d
        AND plan_label LIKE 'SP%%'
    } % [id])[0][0].to_i
  end

  def in_both_dp_count
    local_government_area_records.dp.in_lpi.count
  end

  def in_both_parent_sp_count
    local_government_area_records.sp.select('DISTINCT dp_plan_number').in_lpi.count
  end

  def only_in_council_dp_count
    local_government_area_records.dp.not_in_lpi.count
  end

  def only_in_council_parent_sp_count
    local_government_area_records.sp.not_in_lpi.count
  end

  def only_in_lpi_dp_count
    missing_dp_lpi_records_count
  end
  def only_in_lpi_parent_sp_count
    missing_sp_lpi_records_count
  end
  def in_retired_lpi_dp_count
    connection.query(%{
      SELECT COUNT(DISTINCT(lpi_records.title_reference))
      FROM local_government_area_records lga_records
      JOIN land_and_property_information_records lpi_records
        ON lpi_records.id = lga_records.land_and_property_information_record_id
      WHERE lga_records.local_government_area_id = %d
        AND lpi_records.plan_label LIKE 'DP%%'
        AND lpi_records.retired = TRUE
    } % [id])[0][0].to_i
  end
  def in_retired_lpi_parent_sp_count
    connection.query(%{
      SELECT COUNT(DISTINCT(lpi_records.title_reference))
      FROM local_government_area_records lga_records
      JOIN land_and_property_information_records lpi_records
        ON lpi_records.id = lga_records.land_and_property_information_record_id
      WHERE lga_records.local_government_area_id = %d
        AND lpi_records.plan_label LIKE 'SP%%'
        AND lpi_records.retired = TRUE
    } % [id])[0][0].to_i
  end
end
