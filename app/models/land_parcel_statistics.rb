class LandParcelStatistics

  include ImportStatisticsSet

  requires_attributes :council_unique_dp, :council_unique_parent_sp,
                      :lpi_unique_dp, :lpi_unique_parent_sp

  def council_total
    council_unique_dp + council_unique_parent_sp
  end

  def lpi_total
    lpi_unique_dp + lpi_unique_parent_sp
  end
end
