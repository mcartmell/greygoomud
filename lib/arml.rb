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
#				EventMachine::Synchrony::ConnectionPool.new(size: 20) do
					mongolab = URI.parse(mongo_url)
					conn = EM::Mongo::Connection.new mongolab.host, mongolab.port
					db = conn.db(mongolab.path[1..-1])
					result = EM::Synchrony.sync db.authenticate mongolab.user, mongolab.password
#				end
      else
        conn = EM::Mongo::Connection.new('localhost')
				db = conn.db("arml")
      end
      @@db = db
    end
end
