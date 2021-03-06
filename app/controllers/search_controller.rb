class SearchController < AuthenticatedController

  respond_to :html

  before_filter :find_parameters

  def index
    add_breadcrumb "Search results for \"#{@search_filter}\""
    unless @search_filter.blank?
      if @search_type == "Address"
        @paginated = true
        address_search
      else
        @paginated = false
        title_reference_search
      end
    end
  end

  protected

  def pagination
    {
      :paginate => {
        :page => @page,
        :per_page => 200
      }
    }
  end

  def address_search
    @land_parcel_records = LandParcelRecord.search_by_address(@search_filter,
      pagination.merge!(restrict_search))
  end

  def title_reference_search
    @land_parcel_records = LandParcelRecord.search(@search_filter, restrict_search)
     # If the search is for a common property specifically.
    if @search_filter.starts_with?("//SP") && @land_parcel_records.length > 1
      redirect_to title_reference_url(@search_filter)

    # If the search is for something else, but there was only one result.
    elsif @land_parcel_records.length == 1
      land_parcel = @land_parcel_records.first
      redirect_to title_reference_url(land_parcel.title_reference)
    end
  end

  private

  def find_parameters
    @search_filter = params[:filter]
    @search_type = params[:search_type]
    @page = params[:page] || 1
  end

  def restrict_search
    {}.tap do |where|
      if current_user.admin? && !params[:council_id].blank?
        where[:local_government_area_id] = [params[:council_id]]

      elsif !current_user.admin?
        user_lga_ids = current_user.local_government_area_ids
        where[:local_government_area_id] = user_lga_ids

        unless params[:council_id].blank?
          if user_lga_ids.include? params[:council_id].to_i
            where[:local_government_area_id].push params[:council_id]
          else
            raise "You do not have access to search this LGA"
          end
        end
      end
    end
  end

  def title_reference_url(title_reference)
    url_for(:controller => 'land_parcel_records', :action => 'show',
      :id => title_reference)
  end

end
