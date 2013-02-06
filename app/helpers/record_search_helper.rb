module RecordSearchHelper

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods

    def search(filter, conditions={}, *fields)
      filter_conditions = fields.zip(filter.split('/').reverse).reject { |k, v|
        v.nil? || v.strip.empty?
      }
      where(Hash[filter_conditions].merge(conditions))
    end

  end

end
