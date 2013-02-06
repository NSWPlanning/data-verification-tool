module RecordSearchHelper

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods

    def search(filter, section_number, plan_number, lot_number)
      filters = filter.split('/')
      if filters.length >= 1 &&
        (filters.last.starts_with?("DP") || filters.last.starts_with?("SP"))
        query = ["#{section_number} = ?"]
        variables = [filters.pop]
        if filters.length >= 1
          query.push 'AND', "(", "#{plan_number} = ANY(?)"
          query.push (filters.length == 1) ? 'OR' : 'AND'
          query.push "#{lot_number} = ANY(?)", ")"
          filters = "{#{filters.join(",")}}"
          variables.push filters, filters
        end
        query = query.join(" ")

        find(:all, :conditions => [query, variables].flatten(1))
      else
        []
      end
    end

  end

end
