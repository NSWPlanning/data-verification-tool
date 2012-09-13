class AddInvalidRecordsToLocalGovernmentAreaRecordImportLogs < ActiveRecord::Migration
  def change
    add_column :local_government_area_record_import_logs, :invalid_records, :text
  end
end
