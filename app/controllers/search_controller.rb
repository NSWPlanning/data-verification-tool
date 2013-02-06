class SearchController < ApplicationController

  respond_to :html

  def index
    filter = params[:filter]

    lpi_records = LandAndPropertyInformationRecord.search(filter).all
    lga_records = LocalGovernmentAreaRecord.search(filter).all

    @land_title_to_records = resolve_records(lpi_records, lga_records)
  end

  protected

  def resolve_records(lpi_records = [], lga_records = [])
    lpi_records = Hash[lpi_records.map { |r| [r.title_reference, r] }]
    lga_records = Hash[lga_records.map { |r| [r.title_reference, r] }]

    lga_records.merge(lpi_records) { |key, lpir, lgar| [lpir, lgar] }
  end

end
