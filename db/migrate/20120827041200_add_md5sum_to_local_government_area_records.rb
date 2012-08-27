class AddMd5sumToLocalGovernmentAreaRecords < ActiveRecord::Migration
  def change
    add_column :local_government_area_records, :md5sum, :string, :limit => 32,
      :null => false
  end
end
