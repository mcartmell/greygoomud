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
					puts mongo_url
#				EventMachine::Synchrony::ConnectionPool.new(size: 20) do
					mongolab = URI.parse(mongo_url)
					puts "still here\n"
					conn = EM::Mongo::Connection.new mongolab.host, mongolab.port, 1, {:reconnect_in => 1}
					db = conn.db mongolab.path[1..-1]
					resp = db.authenticate mongolab.user, mongolab.password
					puts resp.inspect
					db
#				end
    #    uri = URI.parse(ENV["ARML_MONGO_URI"])
		#		conn = EM::Mongo::Connection.new(uri.host, uri.port, 1, {:reconnect_in => 1})
		#		puts uri
		#		db = conn.db uri.path[1..-1]
		#		puts "authenticating to #{uri.path[1..-1]} with #{uri.user} and #{uri.password}"
		#		p db.authenticate(uri.user,uri.password)
      else
        conn = EM::Mongo::Connection.new('localhost')
				db = conn.db("arml")
      end
      @@db = db
    end
end
