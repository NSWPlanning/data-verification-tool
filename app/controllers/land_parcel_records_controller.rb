class LandParcelRecordsController < ApplicationController

  respond_to :html

  before_filter :add_landparcel_breadcrumb

  def show
    @land_parcel_record = LandParcelRecord.new(params[:id])

    add_breadcrumb @land_parcel_record.title_reference
  end

  protected

  def add_landparcel_breadcrumb
    add_breadcrumb "Land Parcels"
  end

end
