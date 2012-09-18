class AddLpiComparisonToLocalGovernmentAreaRecordImportLogs < ActiveRecord::Migration
  def change
    add_column :local_government_area_record_import_logs, :lpi_comparison, :text
  end
end
