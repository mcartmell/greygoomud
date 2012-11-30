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

      if mongo_url = ENV["ARML_MONGO_URI"]
        uri = URI.parse(ENV["ARML_MONGO_URI"])
				conn = EM::Mongo::Connection.new(uri.host, uri.port)
				puts uri
				db = conn.db uri.path[1..-1]
				puts "authenticating to #{uri.path[1..-1]} with #{uri.user} and #{uri.password}"
				db.authenticate uri.user,uri.password
      else
        conn = EM::Mongo::Connection.new('localhost')
      end
      @@db = conn.db('arml')
    end
end
