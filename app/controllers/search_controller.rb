class SearchController < AuthenticatedController

  respond_to :html

  def index
    @search_filter = params[:filter]
    add_breadcrumb "Search results for \"#{@search_filter}\""
    unless @search_filter.blank?
      @land_parcel_records = LandParcelRecord.search(@search_filter, restrict_search)
    end
  end

  protected

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

end
