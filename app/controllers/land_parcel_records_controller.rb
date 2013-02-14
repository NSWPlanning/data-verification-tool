class LandParcelRecordsController < ApplicationController

  respond_to :html

  def show
    @land_parcel_record = LandParcelRecord.new(params[:id])
  end

end
