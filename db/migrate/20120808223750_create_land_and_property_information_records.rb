class CreateLandAndPropertyInformationRecords < ActiveRecord::Migration
  def change
    create_table :land_and_property_information_records do |t|
      t.string :cadastre_id, :null => false
      t.string :lot_number
      t.string :section_number
      t.string :plan_label
      t.string :title_reference, :null => false
      t.string :lga_name, :null => false
      t.string :start_date
      t.string :end_date
      t.string :modified_date
      t.string :last_update
      t.string :md5sum, :null => false, :limit => 32
      t.references :local_government_area

      t.timestamps
    end
    add_index :land_and_property_information_records, 
      [:cadastre_id, :local_government_area_id],
      :name => 'lpi_cadastre_id_lga_id', :unique => true
  end
end
