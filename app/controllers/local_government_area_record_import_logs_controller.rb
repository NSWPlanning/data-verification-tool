class LocalGovernmentAreaRecordImportLogsController < AdminController

  skip_before_filter :require_admin!, :only => [:show]

  def show
    @local_government_area = local_government_area_scope.find(
      params[:local_government_area_id]
    )
    # FIXME
    @local_government_area_record_import_log =
      @local_government_area.local_government_area_record_import_logs.find(params[:id])
    @council_file_statistics =
      @local_government_area_record_import_log.council_file_statistics
    @invalid_records =
      @local_government_area_record_import_log.invalid_records
    @land_parcel_statistics =
      @local_government_area_record_import_log.land_parcel_statistics
    @title = @local_government_area.name
  end

  protected
  def local_government_area_scope
    if current_user.admin?
      LocalGovernmentArea
    else
      current_user.send(:local_government_areas)
    end
  end
end
