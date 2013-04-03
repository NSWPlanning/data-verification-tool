class CreateNonStandardInstrumentationZoneImportLog < ActiveRecord::Migration
  def change
    create_table :non_standard_instrumentation_zone_import_logs do |t|
      t.string :filename
      t.references :user
      t.references :local_government_area
      t.integer :processed, :default => 0
      t.integer :created, :default => 0
      t.integer :updated, :default => 0
      t.integer :deleted, :default => 0
      t.integer :error_count, :default => 0
      t.boolean :finished, :default => false
      t.boolean :success, :default => false
      t.datetime :finished_at

      t.timestamps
    end

    add_index :non_standard_instrumentation_zone_import_logs, :user_id
    add_index :non_standard_instrumentation_zone_import_logs,
      :local_government_area_id, :name => 'index_nsi_import_log_nsi_id'
  end
end
