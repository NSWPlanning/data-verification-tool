class LandParcelRecordsController < AuthenticatedController

  respond_to :html, :json

  before_filter :find_land_parcel, :scope => :show
  before_filter :authenticate_land_parcel, :scope => :show

  def show
    add_breadcrumb @land_parcel_record.title_reference
  end

  protected

  def find_land_parcel
    begin
      @land_parcel_record = LandParcelRecord.new(params[:id])
    rescue LandParcelRecord::RecordNotFound => e
      raise ActiveRecord::RecordNotFound.new
    end
  end

  def authenticate_land_parcel
    unless current_user.admin?
      land_parcel_lgas = @land_parcel_record.local_government_areas
      user_lgas = current_user.local_government_areas
      intersection = (land_parcel_lgas & user_lgas)
      if intersection.blank? && !current_user.admin?
        flash[:alert] = "You do not have access to this land parcel"
        redirect_to :root
      end
    end
  end

  def format_json?
    request.format.json?
  end

end
