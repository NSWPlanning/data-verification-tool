class LocalGovernmentAreasController < AdminController

  # Skipping this filter does not mean *any* user can view the resource.
  # Access is still controlled by the find_model method, which won't allow
  # users who don't have access to this LGA.
  skip_before_filter :require_admin!, :only => [
    :index, :show, :uploads, :detail, :error_records, :import, :only_in_council, :only_in_lpi
  ]

  # Allows API access to certain methods - skips here should be paired with 
  # calls in allow_api_access
  API_ACTIONS = [:import, :only_in_council, :only_in_lpi, :error_records]
  skip_before_filter :verify_authenticity_token, :if => :format_json?, :only => API_ACTIONS
  skip_before_filter :require_login, :if => :format_json?, :only => API_ACTIONS
  before_filter :require_http_auth, :if => :format_json?, :only => API_ACTIONS


  # Setup breadcrumbs
  add_breadcrumb 'All Councils', '', :only => [:index]

  include ResourceController

  def uploads
    @local_government_area = find_model(params[:id])
    LocalGovernmentAreaRecordImporter.enqueue(
      @local_government_area, params[:data_file], current_user
    )
    respond_to do |format|
      format.html { redirect_to @local_government_area,
                    :notice => 'Your data file will be processed shortly.' }
      format.json { render :nothing =>true, :status => :ok }
    end
  end

  # The /import action is exactly the same as the /uploads action, except that
  # it passes through a different set of before filters.
  alias :import :uploads

  def error_records
    @local_government_area = find_model(params[:id])
    @title = "Error records for #{@local_government_area.name}"
    add_council_and_import_breadcrumbs
    add_breadcrumb "Errors", ''
  end

  def only_in_council
    @local_government_area = find_model(params[:id])
    add_council_and_import_breadcrumbs
    add_breadcrumb "Only In Council", ''
    @source_field_name = 'Council ID'
    @source_field_id = 'council_id' 
  end

  def only_in_lpi
    @local_government_area = find_model(params[:id])
    add_council_and_import_breadcrumbs
    add_breadcrumb "Only In LPI", ''
    @source_field_name = 'CADID'
    @source_field_id = 'cadastre_id'
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

  def add_council_and_import_breadcrumbs
    add_breadcrumb "#{@local_government_area.name}", 'local_government_area_path(@local_government_area.id)'
    # Import date breadcrumb
    lga = @local_government_area
    add_breadcrumb lga.most_recent_import_date.strftime("%-d %b %y"),
                   local_government_area_detail_path(lga.id, lga.most_recent)
  end

  def format_json?
    request.format.json?
  end
end
