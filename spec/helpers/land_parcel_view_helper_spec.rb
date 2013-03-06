require 'spec_helper'

describe LandParcelViewHelper do

  describe "#link_to_land_parcel" do

    it "should return a link to the land parcel with the provided title_reference" do
      link_to_land_parcel("1/2/DP123").should include "1/2/DP123"
    end

  end

end
