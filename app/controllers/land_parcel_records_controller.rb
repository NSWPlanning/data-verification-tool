class LandParcelRecordsController < ApplicationController

  respond_to :html

  def show
    @land_parcel_record = LandParcelRecord.new(params[:id])

    add_breadcrumb @land_parcel_record.title_reference
  end

end
