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

  include ResourceController
  alias :rc_index :index

  def index
    @title = 'All Councils'
    rc_index
  end

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
  end

  protected
  def require_http_auth
    authenticate_with_http_basic do |username, password|
      current_user = login(username, password)
    end
    render :nothing => true, :status => :forbidden unless current_user
  end
end
