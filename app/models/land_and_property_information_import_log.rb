class LandAndPropertyInformationImportLog < ActiveRecord::Base
  belongs_to :user
  attr_accessible :created, :error_count, :filename, :finished, :processed, :success,
    :updated, :user_id, :finished_at

  attr_accessor :importer

  def self.start!(importer)
    create!(
      :filename => importer.filename, :user_id => importer.user.id
    ).tap do |import_log|
      import_log.importer = importer
    end
  end

  def complete!
    update_attributes(
      importer_attributes.merge(
        :success => true, :finished => true, :finished_at => Time.now
      )
    )
  end

  def fail!
    update_attributes(
      importer_attributes.merge(
        :success => false, :finished => true, :finished_at => Time.now
      )
    )
  end

  def started_at
    created_at
  end

  protected
  def importer_attributes
    {
      :processed => importer.processed, :created => importer.created,
      :updated => importer.updated, :error_count => importer.error_count,
    }
  end
end
