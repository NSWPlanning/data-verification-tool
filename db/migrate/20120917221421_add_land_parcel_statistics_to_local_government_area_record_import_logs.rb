class AddLandParcelStatisticsToLocalGovernmentAreaRecordImportLogs < ActiveRecord::Migration
  def change
    add_column :local_government_area_record_import_logs, :land_parcel_statistics, :text
  end
end
