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
  #   # DP1234 appears 5 times, DP6789 appears 10 times for the LGA
  #   [
  #     ['DP1234', '5'],
  #     ['DP6789', '10'],
  #   ]
  def duplicate_dp_records
    connection.query(%{
      SELECT dp_plan_number, COUNT(dp_plan_number) AS duplicate_count
      FROM local_government_area_records
      WHERE dp_plan_number LIKE 'DP%%' AND local_government_area_id = %d
      GROUP BY dp_plan_number
      HAVING (COUNT(dp_plan_number) > 1)
    } % [id])
  end

  def mark_duplicate_dp_records_invalid
    connection.query(%{
      UPDATE local_government_area_records
      SET is_valid = FALSE
      WHERE dp_plan_number IN (
        SELECT dp_plan_number
        FROM local_government_area_records
        WHERE dp_plan_number LIKE 'DP%%' AND local_government_area_id = %d
        GROUP BY dp_plan_number
        HAVING (COUNT(dp_plan_number) > 1)
      )
      AND local_government_area_id = %d
    } % [id, id])
  end

end
