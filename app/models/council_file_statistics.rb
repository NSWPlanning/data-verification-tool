class CouncilFileStatistics

  include ImportStatisticsSet

  requires_attributes :dp_records, :sp_records

  def total
    dp_records + sp_records
  end
  
end
