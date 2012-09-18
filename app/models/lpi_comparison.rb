class LpiComparison

  include ImportStatisticsSet

  requires_attributes :in_both_dp, :in_both_parent_sp, :only_in_council_dp,
      :only_in_council_parent_sp, :only_in_lpi_dp, :only_in_lpi_parent_sp,
      :in_retired_lpi_dp, :in_retired_lpi_parent_sp

  has_total :in_both_total,
    :in_both_dp, :in_both_parent_sp
  has_percentage_for :in_both_total, :divisor => :total_total

  has_total :only_in_council_total,
    :only_in_council_dp, :only_in_council_parent_sp
  has_percentage_for :only_in_council_total, :divisor => :total_total

  has_total :only_in_lpi_total,
    :only_in_lpi_dp, :only_in_lpi_parent_sp
  has_percentage_for :only_in_lpi_total, :divisor => :total_total

  has_total :in_retired_lpi_total,
    :in_retired_lpi_dp, :in_retired_lpi_parent_sp
  has_percentage_for :in_retired_lpi_total, :divisor => :total_total

  has_total :total_dp,
    :in_both_dp, :only_in_council_dp, :only_in_lpi_dp, :in_retired_lpi_dp
  has_total :total_parent_sp,
    :in_both_parent_sp, :only_in_council_parent_sp, :only_in_lpi_parent_sp, :in_retired_lpi_parent_sp
  has_total :total_total,
    :in_both_total, :only_in_council_total, :only_in_lpi_total,
    :in_retired_lpi_total
  has_percentage_for :total_total, :divisor => :total_total
end
