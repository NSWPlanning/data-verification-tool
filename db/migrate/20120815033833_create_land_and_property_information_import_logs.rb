class CreateLandAndPropertyInformationImportLogs < ActiveRecord::Migration
  def change
    create_table :land_and_property_information_import_logs do |t|
      t.string :filename
      t.references :user
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
    add_index :land_and_property_information_import_logs, :user_id
  end
end
