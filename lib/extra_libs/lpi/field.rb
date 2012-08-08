module LPI
  class Field
    attr_reader :name, :aliases
    def initialize(name, options = {})
      @name = name
      @aliases = options[:aliases] || []
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
