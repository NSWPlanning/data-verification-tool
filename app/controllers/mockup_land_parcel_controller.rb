class MockupLandParcelController < AdminController

  skip_before_filter :require_admin!, :only => [:show]

  def index
    add_breadcrumb 'Land Parcel Mockups'
  end

  def valid_dp
    add_breadcrumb '6//DP270331'
  end

  def valid_sp
    add_breadcrumb '1//SP22805'
  end

  def valid_sp_cp
    add_breadcrumb '//SP22805'
  end

  def only_in_council
    add_breadcrumb 'foo'
  end

  def only_in_lpi
    add_breadcrumb 'foo'
  end

  def invalid_one
    add_breadcrumb 'foo'
  end    

  def invalid_multiple
    add_breadcrumb 'foo'
  end    

  def in_multiple_lgas
    add_breadcrumb 'foo'
  end

  protected
  def human_singular_name
    "Land Parcel"
  end
end
