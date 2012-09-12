class DataQuality

  def self.has_percentage_for(collection)
    percentage_method = "#{collection}_percentage" 

    define_method percentage_method do
      (send(collection).to_f / total.to_f) * 100
    end
  end

  def self.requires_attributes(*attributes)
    @required_attributes = attributes
    @required_attributes.each do |attr|
      attr_accessor attr
    end
  end

  def self.required_attributes
    @required_attributes
  end

  requires_attributes :in_council_and_lpi, :only_in_lpi, :only_in_council,
                      :total

  has_percentage_for :in_council_and_lpi
  has_percentage_for :only_in_lpi
  has_percentage_for :only_in_council

  def initialize(attributes)
    self.class.required_attributes.each do |attr|
      if !attributes.has_key?(attr) or attributes[attr].nil?
        raise ArgumentError, ":#{attr} must be present and not nil"
      end
      self.send("#{attr}=", attributes[attr])
    end
  end

end
