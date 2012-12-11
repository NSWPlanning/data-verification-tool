require 'digest/md5'
module DVT
  module Base
    class Record

      attr_reader :row, :line

      def initialize(row, line)
        @row  = row
        @line = line
      end

      # Returns a checksum for this record, based on the CSV line content.
      # Note that the checksum includes the trailing EOL character from the
      # CSV record.
      def md5sum
        @md5sum ||= Digest::MD5.hexdigest(self.to_checksum_string)
      end

      def to_checksum_string
        row.to_csv
      end

      def valid?
        has_required_fields?
      end

      def has_required_fields?
        self.class.required_fields.all? do |field|
          row.include? field
        end
      end

      # Convert this object to a Hash.  For each field on the object, if
      # aliases are present, the first alias in the array is used as the hash
      # key.  Otherwise the downcased CSV field name is used.
      def to_hash
        Hash[self.class.attributes.map {|attr| [attr, send(attr)]}]
      end

      def self.header_fields
        required_fields
      end

      def self.required_fields
        fields.select {|field| field if field.required}.map(&:name)
      end

      def self.attributes
        fields.map(&:to_attribute) + extra_attributes
      end

      def self.extra_attributes
        []
      end

      def self.fields
        @fields ||= []
      end

      # Creates accessor methods for the given RecordField on this record.
      # For the following RecordField:
      #
      #   RecordField.new('Foo', :alias => ['bar', 'baz']
      #
      # this method will create:
      #
      #   record.foo
      #   record.bar
      #   record.baz
      #
      # Which will each return the value of row['Foo'] from the CSV row.
      def self.add_accessor_methods_for(field)
        method_name = field.name.downcase
        define_method method_name do
          row[field.name]
        end
        field.aliases.each do |field_alias|
          alias_method field_alias, method_name
        end
      end

      # Adds a field to the field definitions list, and creates accessor methods
      # for the field with #add_accessor_methods_for
      #
      # E.g.
      #
      #   has_field 'Foo', :aliases => ['bar', 'baz']
      #
      # Will create a new RecordField as follows:
      #
      #   RecordField.new('Foo', :aliases => ['bar', 'baz']
      #
      def self.has_field(*args)
        field = RecordField.new(*args)
        fields.push(field)
        add_accessor_methods_for(field)
      end
    end
  end
end
