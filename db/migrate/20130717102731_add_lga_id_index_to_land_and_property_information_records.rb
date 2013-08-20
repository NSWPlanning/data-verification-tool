class AddLgaIdIndexToLandAndPropertyInformationRecords < ActiveRecord::Migration
  def change
    add_index :land_and_property_information_records, :local_government_area_id, { name: 'lga_id_index' }
      # default index name is too long; override the name.
  end
end
