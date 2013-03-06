module LandParcelViewHelper

  def link_to_land_parcel(title_reference)
    link_to(title_reference, url_for(
      :controller => 'land_parcel_records',
      :action => 'show',
      :id => title_reference))
  end

end
