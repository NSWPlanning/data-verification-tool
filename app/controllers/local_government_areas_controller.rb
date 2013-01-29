class LocalGovernmentAreasController < AdminController

  # Skipping this filter does not mean *any* user can view the resource.
  # Access is still controlled by the find_model method, which won't allow
  # users who don't have access to this LGA.
  skip_before_filter :require_admin!, :only => [
    :index, :show, :uploads, :detail, :error_records, :import
  ]

  # Ensure that authentication goes through HTTP basic auth for the import
  # action
  skip_before_filter :verify_authenticity_token, :only => [:import]
  skip_before_filter :require_login, :only => [:import]
  before_filter :require_http_auth, :only => [:import]

  # Setup breadcrumbs
  add_breadcrumb 'All Councils', '', :only => [:index]

  include ResourceController

  def uploads
    @local_government_area = find_model(params[:id])
    LocalGovernmentAreaRecordImporter.enqueue(
      @local_government_area, params[:data_file], current_user
    )
    redirect_to @local_government_area,
      :notice => 'Your data file will be processed shortly.'
  end

  # The /import action is exactly the same as the /uploads action, except that
  # it passes through a different set of before filters.
  alias :import :uploads

  def error_records
    @local_government_area = find_model(params[:id])
    @title = "Error records for #{@local_government_area.name}"
    add_breadcrumb "#{@local_government_area.name}", 'local_government_area_path(@local_government_area.id)'
    # We only have error records for most recent import, but show import date in breadcrumbs for consistency
    lga = @local_government_area
    add_breadcrumb lga.most_recent_import_date.strftime("%-d %b %y"),
                   local_government_area_detail_path(lga.id, lga.most_recent)
    add_breadcrumb "Errors", ''
  end

  protected
  def require_http_auth
    authenticate_with_http_basic do |username, password|
      current_user = login(username, password)
    end
    render :nothing => true, :status => :forbidden unless current_user
  end

  def human_singular_name
    "Council"
  end
end
