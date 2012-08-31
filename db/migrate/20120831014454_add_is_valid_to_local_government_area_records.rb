class AddIsValidToLocalGovernmentAreaRecords < ActiveRecord::Migration
  def change
    add_column :local_government_area_records, :is_valid, :boolean,
      :default => true
  end
end
