class SearchController < ActionController::Base

  def index
    filter = params[:filter]

    @lpi_records = LandAndPropertyInformationRecord.search(filter).all
  end

end
