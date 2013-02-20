module RecordSearchHelper

  class InvalidSearchFilter < StandardError; end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods

    def search(filter, conditions={}, *fields)
      filter_conditions = []
      if !filter.blank?
        filter_conditions = fields.zip(filter.split('/').reverse).reject { |k, v|
          v.nil? || v.strip.empty?
        }
      end

      unless filter_conditions.blank?
        where(Hash[filter_conditions].merge(conditions))
      else
        raise InvalidSearchFilter.new("Not enough information to narrow selection.")
      end
    end

  end

end
