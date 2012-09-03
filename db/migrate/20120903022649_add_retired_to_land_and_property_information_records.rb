class AddRetiredToLandAndPropertyInformationRecords < ActiveRecord::Migration
  def change
    add_column :land_and_property_information_records, :retired, :boolean,
      :default => false
  end
end
