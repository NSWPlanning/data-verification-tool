class AddLgaIdIndexToLocalGovermentAreaRecords < ActiveRecord::Migration
  def change
    add_index :local_government_area_records, :local_government_area_id
  end
end
