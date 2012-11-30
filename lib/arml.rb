require "arml/room"
require "arml/base"
require "em-mongo"
require 'eventmachine'

class Arml

    @@db = nil

    def self.db
      return @@db if @@db
      db = ""
			conn = ""

      if mongo_url = ENV["ARML_MONGO_URL"]
        uri = URI.parse(ENV["ARML_MONGO_URL"])
				conn = EM::Mongo::Connection.from_uri(uri.host, uri.port)
      else
        conn = EM::Mongo::Connection.new('localhost')
      end
      @@db = conn.db('arml')
    end
end
