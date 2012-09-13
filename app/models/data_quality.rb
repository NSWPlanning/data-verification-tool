class DataQuality

  include ImportStatisticsSet

  requires_attributes :in_council_and_lpi, :only_in_lpi, :only_in_council,
                      :total

  has_percentage_for :in_council_and_lpi
  has_percentage_for :only_in_lpi
  has_percentage_for :only_in_council

end