require "em-mongo"
require 'eventmachine'

class Arml
	class Id
		attr_reader :key, :id

		def ==(other_id)
			return self.id == other_id.id
		end

		def initialize(key, id)
			if !id.is_a?(BSON::ObjectId)
				raise "didn't get a bson id"
			end
			@key = key
			@id = id
		end

		def to_href
			return "#{ENV['ARML_URI_PREFIX']}/#{key}/#{to_s}"
		end

		def to_s
			return "#{key}-#{id}"
		end

		def self.from_string(str)
			key,id = str.split(/-/)	
			return self.new(key,BSON::ObjectId.from_string(id))
		end

		def to_db
			return {
				:key => key,
				:id => id
			}
		end

		def self.from_db(hash)
			return self.new(hash["key"], hash["id"])
		end
	end

		class Error < Exception
		end

		# when classes inherit Arml::Base, remember their db_keys
		@@collection_classes = []
		@@collection_to_class_map = nil

    @@db = nil
		@@dbname = "arml"
		@@cache = {}

		def self.collection_to_class_map
			return @@collection_to_class_map if @@collection_to_class_map
			@@collection_to_class_map = {}
			ar = collection_classes()
			ar.each do |e|
				# some classes don't have a db key, so ignore them
				begin
					@@collection_to_class_map[e.db_key] = e
				rescue
				end
			end
			@@collection_to_class_map
		end

		def self.collection_to_class(name)
			collection_to_class_map[name]
		end

		def self.collection_classes
			@@collection_classes
		end

# The database accessor
		def self.dbconn
			# occasionally it'll disconnect after a query for no reason. this seems
			# decent protection.
			return @@db if @@db && @@db.connected?
      db = ""
			conn = ""

      if mongo_url = ENV["ARML_MONGO_URI"]
				db = EM::Synchrony::ConnectionPool.new(size: 1) do
					mongolab = URI.parse(mongo_url)
					conn = EM::Mongo::Connection.new mongolab.host, mongolab.port, 1
					@@dbname = mongolab.path[1..-1]
					EM::Synchrony.sync db.authenticate mongolab.user, mongolab.password
					conn
				end
      else
				db = EM::Synchrony::ConnectionPool.new(size: 1) do
					conn = EM::Mongo::Connection.new('localhost')
				end
      end
      @@db = db
    end

		def self.db
			return self.dbconn.db(@@dbname)
		end

    def self.sync(df)
      f = Fiber.current
			myxback = lambda do |type|
      xback = proc do |*args|
        if f == Fiber.current
          return args.size == 1 ? args.first : args
        else
          f.resume(*args)
        end
      end
			return xback
			end

      df.timeout(3)
			myx = myxback.call(2)
      df.callback(&myx)
      df.errback(&myx)

      Fiber.yield
    end

		def self.db_id_to_id(obj, db_id)
			return Arml::Id.new(obj.db_key, db_id)
		end

# Find an object by id regardless of its collection
		def self.find(arml_id)
			collection_to_class(arml_id.key).load(arml_id.id)	
		end
		def self.find_s(str)
			return find(Arml::Id.from_string(str))
		end
end

require "arml/room"
require "arml/player"
require "arml/object"
require "arml/base"
