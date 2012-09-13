class AddCouncilFileStatisticsToLocalGovernmentAreaRecordImportLogs < ActiveRecord::Migration
  def change
    add_column :local_government_area_record_import_logs, :council_file_statistics, :text
  end
end
