class AddDataQualityToLocalGovernmentAreaRecordImportLogs < ActiveRecord::Migration
  def change
    add_column :local_government_area_record_import_logs, :data_quality, :text
  end
end
