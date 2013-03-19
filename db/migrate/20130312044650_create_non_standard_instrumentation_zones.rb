class CreateNonStandardInstrumentationZones < ActiveRecord::Migration
  def change
    create_table :non_standard_instrumentation_zones do |t|
      t.references :local_government_area

      t.integer :council_id

      t.text :date_of_update
      t.text :lep_nsi_zone
      t.text :lep_si_zone
      t.text :lep_name

      t.string :md5sum, :limit => 32, :null => false

      t.timestamps
    end
    add_index :non_standard_instrumentation_zones, :local_government_area_id,
      :name => 'index_nsi_local_government_area_id'
    add_index :non_standard_instrumentation_zones, :council_id,
      :name => 'index_nsi_council_id'
  end
end
