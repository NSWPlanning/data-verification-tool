class NonStandardInstrumentationZoneImportLogsController < AdminController

  skip_before_filter :require_admin!, :only => [:show]

  def show
    @local_government_area = local_government_area_scope.find(
      params[:local_government_area_id]
    )

    @non_standard_instrumentation_zone_import_log =
      @local_government_area.non_standard_instrumentation_zone_import_logs.find(params[:id])

    @most_recent = (@non_standard_instrumentation_zone_import_log == @local_government_area.most_recent)

    @title = @local_government_area.name

    add_breadcrumb @local_government_area.name, 'local_government_area_path(@local_government_area.id)'
    # breadcrumb of the date the import finished, so users know which import they're looking at.
    add_breadcrumb @local_government_area.most_recent_import_date.strftime("%-d %b %y"), ''
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
