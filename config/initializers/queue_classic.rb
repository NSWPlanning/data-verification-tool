require 'queue_classic'

module QC
  module Conn
    def self.connection=(connection)
      unless connection.instance_of? PG::Connection
        raise(
          ArgumentError,
          "connection must be an instance of PG::Connection, but was #{connection.class}"
        )
      end
      @connection = connection
    end
  end
end

QC::Conn.connection = ActiveRecord::Base.connection.raw_connection
