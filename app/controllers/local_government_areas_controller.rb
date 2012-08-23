class LocalGovernmentAreasController < AdminController
  skip_before_filter :require_admin!, :only => [:index, :show, :uploads]
  include ResourceController

  def uploads
    @local_government_area = find_model(params[:id])
    LocalGovernmentAreaRecordImporter.enqueue(
      @local_government_area, params[:data_file], current_user
    )
    redirect_to @local_government_area,
      :notice => 'Your data file will be processed shortly.'
  end
end
