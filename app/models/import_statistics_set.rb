module ImportStatisticsSet
  module ClassMethods
    def has_percentage_for(collection, options = {})
      percentage_method = "#{collection}_percentage" 
      divisor = options[:divisor] || :total

      define_method percentage_method do
        (send(collection).to_f / send(divisor).to_f) * 100
      end
    end

    # Sends self each message in terms and returns the sum.
    # All terms must return integers.
    def has_total(method_name, *terms)
      define_method method_name do
        terms.inject(0) do |memo, term|
          memo + send(term)
        end
      end
    end

    def requires_attributes(*attributes)
      @required_attributes = attributes
      @required_attributes.each do |attr|
        attr_accessor attr
      end
    end

    def required_attributes
      @required_attributes
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def initialize(attributes)
    self.class.required_attributes.each do |attr|
      if !attributes.has_key?(attr) or attributes[attr].nil?
        raise ArgumentError, ":#{attr} must be present and not nil"
      end
      self.send("#{attr}=", attributes[attr])
    end
  end

end
