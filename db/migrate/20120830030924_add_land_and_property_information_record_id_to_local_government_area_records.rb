class AddLandAndPropertyInformationRecordIdToLocalGovernmentAreaRecords < ActiveRecord::Migration
  def up
    change_table :local_government_area_records do |t|
      t.references :land_and_property_information_record
    end
  end

  def down
    remove_column :local_government_area_records, 
      :land_and_property_information_record_id
  end
end
