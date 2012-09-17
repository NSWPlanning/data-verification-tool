class LocalGovernmentAreaRecordImportLog < ActiveRecord::Base

  belongs_to :local_government_area

  attr_accessible :local_government_area, :local_government_area_id

  LocalGovernmentArea.statistics_set_names.each do |statistic_set|
    require statistic_set.to_s
    attr_accessible statistic_set
    serialize statistic_set
  end

  def statistics_sets
    Hash[
      LocalGovernmentArea.statistics_set_names.map do |statistics_set|
        [statistics_set, self.send(statistics_set)]
      end
    ]
  end

  include ImportLog

  def self.extra_attributes_for(importer)
    {:local_government_area_id => importer.local_government_area.id}
  end

  alias :original_importer_attributes :importer_attributes
  protected
  def importer_attributes
    original_importer_attributes.merge(
      Hash[
        LocalGovernmentArea.statistics_set_names.map do |statistics_set|
          [statistics_set, importer.send(statistics_set)]
        end
      ]
    )
  end

end
