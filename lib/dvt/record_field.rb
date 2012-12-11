module DVT
  class RecordField
    attr_reader :name, :aliases, :required
    def initialize(name, options = {})
      @name = name
      @aliases = options[:aliases] || []
      @required = true
      @required = options[:required] unless options[:required].nil?
    end

    def to_attribute
      if aliases.first
        aliases.first.to_s.downcase
      else
        name.downcase
      end
    end
  end
end
