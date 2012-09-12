class DataQuality

  attr_reader :local_government_area

  def self.has_stats_for(collection)

    count_method = "#{collection}_count" 
    percentage_method = "#{collection}_percentage" 

    define_method collection do
      local_government_area.send(collection)
    end

    define_method count_method do
      send(collection).count
    end

    define_method percentage_method do
      (send(count_method).to_f / lpi_count.to_f) * 100
    end

  end

  has_stats_for :in_council_and_lpi
  has_stats_for :only_in_lpi
  has_stats_for :only_in_council

  def initialize(local_government_area)
    @local_government_area = local_government_area
  end

  def lpi_count
    @local_government_area.land_and_property_information_records.count
  end

end
