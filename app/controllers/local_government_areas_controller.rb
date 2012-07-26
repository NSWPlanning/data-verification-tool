class LocalGovernmentAreasController < AdminController

  respond_to :html

  def index
    @local_government_areas = LocalGovernmentArea.all
    respond_with @local_government_areas
  end

  def show
    @local_government_area = find_local_government_area(params[:id])
    @title = @local_government_area.to_s
  end

  def new
    @title = 'Create new local government area'
    @local_government_area = LocalGovernmentArea.new
  end

  def create
    @local_government_area = LocalGovernmentArea.new
    @local_government_area.assign_attributes(
      params[:local_government_area], :as => current_role
    )
    @local_government_area.save
    respond_with @local_government_area
  end

  def edit
    @local_government_area = find_local_government_area(params[:id])
    @title = "Edit #{@local_government_area}"
  end

  def update
    @local_government_area = find_local_government_area(params[:id])
    @local_government_area.assign_attributes(
      params[:local_government_area], :as => current_role
    )
    @local_government_area.save
    respond_with @local_government_area
  end

  protected
  def find_local_government_area(id)
    LocalGovernmentArea.find(id)
  end
end
