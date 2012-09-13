# Common behaviour for import loggers
require 'active_support/concern'

module ImportLog

  extend ActiveSupport::Concern

  included do

    belongs_to :user

    attr_accessible :created, :error_count, :filename, :finished, :processed, :success,
      :updated, :user_id, :finished_at

    attr_accessor :importer

    default_scope order('finished_at DESC')

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

  module ClassMethods
    def start!(importer)
      create!(attributes_for(importer)).tap do |import_log|
        import_log.importer = importer
      end
    end

    def attributes_for(importer)
      {
        :filename => importer.filename, :user_id => importer.user.id,
      }.merge(extra_attributes_for(importer))
    end

    def extra_attributes_for(importer)
      {}
    end

    def most_recent
      finished.first
    end

    def finished
      where('finished_at IS NOT NULL')
    end

    def most_recent_import_date
      if most_recent
        most_recent.finished_at.to_date
      end
    end

  end
end
