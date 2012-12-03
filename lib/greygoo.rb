require "em-mongo"
require 'eventmachine'

# A class of utility methods
class GreyGoo
	# Represents an object identifier. Differs from mongo id in that it includes the collection name too

	class Id
		attr_reader :key, :id

# Compares to another id by comparing the unique mongo id
#
# @param [GreyGoo::Id] other_id The id to compare with
# @return [Bool] True if equal
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

# Converts an id to a link
		def to_href
			return "#{ENV['GREYGOO_URI_PREFIX']}/#{key}/#{to_s}"
		end

# Converts to a string
		def to_s
			return "#{key}-#{id}"
		end

# Creates an Id object from a string
#
# @param [String] str The string to coerce
# @return [GreyGoo::Id] The coerced object
		def self.from_string(str)
			key,id = str.split(/-/)	
			return self.new(key,BSON::ObjectId.from_string(id))
		end

# Serializes to a hash
#
# @return [Hash] The serialized id
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

# Represents a generic error
		class Error < Exception
			def to_json
				hash = { "class" => self.class, "message" => message }
				return hash.to_json
			end
		end

		# when classes inherit GreyGoo::Base, remember their db_keys
		@@collection_classes = []
		@@collection_to_class_map = nil

    @@db = nil
		@@dbname = "greygoo"
		@@cache = {}

# This is so we can remember which classes correspond to which mongo
# collections
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

      if mongo_url = ENV["GREYGOO_MONGO_URI"]
				db = EM::Synchrony::ConnectionPool.new(size: 1) do
					mongolab = URI.parse(mongo_url)
					conn = EM::Mongo::Connection.new mongolab.host, mongolab.port, 1
					@@dbname = mongolab.path[1..-1]
					EM::Synchrony.sync conn.db(@@dbname).authenticate mongolab.user, mongolab.password
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
			return GreyGoo::Id.new(obj.db_key, db_id)
		end

# Find an object by id regardless of its collection
		def self.find(greygoo_id)
			collection_to_class(greygoo_id.key).load(greygoo_id.id)	
		end
	
# Coerces a string to an Id then looks it up
#
# @param [String] str
# @return [GreyGoo::Common]
		def self.find_s(str)
			return find(GreyGoo::Id.from_string(str))
		end
end

require "greygoo/room"
require "greygoo/player"
require "greygoo/object"
require "greygoo/base"
