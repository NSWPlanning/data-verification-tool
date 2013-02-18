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

  def inconsistent_sp
    add_breadcrumb '4//SP85521'
  end

  def inconsistent_sp_cp
    add_breadcrumb '//SP85521'
  end

  def only_in_council_dp
    add_breadcrumb '1//DP196232'
  end

  def only_in_council_sp
    add_breadcrumb '31//SP83421'
  end

  def only_in_council_sp_cp
    add_breadcrumb '//SP83421'
  end

  def only_in_lpi
    add_breadcrumb '1//DP590490'
  end

  def invalid_one
    add_breadcrumb 'A//DP155195'
  end    

  def invalid_multiple
    add_breadcrumb 'B//DP155195'
  end    

  def in_multiple_lgas
    add_breadcrumb '99//DP99999'
  end

  def duplicate_dp
    add_breadcrumb '1//DP935306'
  end

  protected
  def human_singular_name
    "Land Parcel"
  end
end
