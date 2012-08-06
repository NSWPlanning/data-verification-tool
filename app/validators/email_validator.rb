require 'mail'
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    parser = Mail::RFC2822Parser.new
    parser.root = :addr_spec
    result = parser.parse(value)
    unless result && result.respond_to?(:domain) && result.domain.dot_atom_text.elements.size > 1
      record.errors[attribute] << (options[:message] || "is invalid")
    end
  end
end
