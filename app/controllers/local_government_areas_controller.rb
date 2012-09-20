class LocalGovernmentAreasController < AdminController

  # Skipping this filter does not mean *any* user can view the resource.
  # Access is still controlled by the find_model method, which won't allow
  # users who don't have access to this LGA.
  skip_before_filter :require_admin!, :only => [
    :index, :show, :uploads, :detail, :error_records
  ]

  include ResourceController

  def uploads
    @local_government_area = find_model(params[:id])
    LocalGovernmentAreaRecordImporter.enqueue(
      @local_government_area, params[:data_file], current_user
    )
    redirect_to @local_government_area,
      :notice => 'Your data file will be processed shortly.'
  end

  def error_records
    @local_government_area = find_model(params[:id])
    @title = "Error records for #{@local_government_area.name}"
  end
end
