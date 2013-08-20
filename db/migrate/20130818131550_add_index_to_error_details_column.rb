class AddIndexToErrorDetailsColumn < ActiveRecord::Migration
  def change
    add_hstore_index :local_government_area_records, :error_details
  end
end
