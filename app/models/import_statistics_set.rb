module ImportStatisticsSet
  module ClassMethods
    def has_percentage_for(collection)
      percentage_method = "#{collection}_percentage" 

      define_method percentage_method do
        (send(collection).to_f / total.to_f) * 100
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
