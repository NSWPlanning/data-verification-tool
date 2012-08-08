module LPI
  class Field
    attr_reader :name, :aliases
    def initialize(name, options = {})
      @name = name
      @aliases = options[:aliases] || []
    end
  end
end
