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
					puts "still here connecting to #{mongolab.host} #{mongolab.port}\n"
					conn = EM::Mongo::Connection.new mongolab.host, mongolab.port
					db = conn.db mongolab.path[1..-1]
					puts "using #{mongolab.user} #{mongolab.password}\n"
					resp = db.authenticate mongolab.user, mongolab.password
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
