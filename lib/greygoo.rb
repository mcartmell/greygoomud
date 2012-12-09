require "em-mongo"
require 'eventmachine'

# A class of utility methods
class GreyGoo
	# Represents an object identifier. Differs from mongo id in that it includes the collection name too

		# when classes inherit GreyGoo::Base, remember their db_keys
		@collection_classes = []

		# the collection to class map
		@collection_to_class_map = nil

		# the database handle
    @db = nil

		# the default database name
		@dbname = "greygoo"

# Represents a generic error
		class Error < Exception

# Converts the error object to json
			def to_json
				hash = { "class" => self.class, "message" => message }
				return hash.to_json
			end
		end

# 404
		class NotFoundError < GreyGoo::Error
		end

# 403
		class PermissionsError < GreyGoo::Error
		end

# 400
		class WrongArgsError < GreyGoo::Error
		end

# Attempts to serialize objects into simple types
#
# @param [Object] v The value to serialize
# @return [Hash] A hash suitable for saving to the database
		def self.serialize(v, type = 'resource')
			if v.is_a?(GreyGoo::Base)
				if type == 'resource'
					return v.id.to_href
				else
					return v.id.to_db
				end
			elsif v.is_a?(Hash)
				hash = {}
				v.each do |k,val|
					hash[k] = serialize(val, type)
				end
				return hash
			elsif v.is_a?(Set)
				return serialize(v.to_a)
			elsif v.is_a?(Array)
				a = []
				v.each_with_index do |item, i|
					a[i] = serialize(item, type)
				end
				return a
			end
			return v
		end

# Attempts to coerce a simple type into an object
# Basically the opposite of #serialize
#
# @param [Object] v The value to coerce
# @return An inflated value
		def self.coerce(v)
			if v.is_a?(Array)
				v = v.map{|item| coerce(item)}.compact.to_set
			elsif v.is_a?(Hash)
				if v["id"].is_a?(BSON::ObjectId)
					greygoo_id = GreyGoo::Id.from_db(v)
					v = GreyGoo.find(greygoo_id)
				else
					v.each do |k,val|
						v[k] = coerce(val)
					end
				end
			end
			return v
		end


# This is so we can remember which classes correspond to which mongo
# collections
		def self.collection_to_class_map
			return @collection_to_class_map if @collection_to_class_map
			@collection_to_class_map = {}
			ar = collection_classes()
			ar.each do |e|
				# some classes don't have a db key, so ignore them
				begin
					@collection_to_class_map[e.db_key] = e
				rescue
				end
			end
			@collection_to_class_map
		end

# returns the class name for the collection
		def self.collection_to_class(name)
			collection_to_class_map[name]
		end

# returns the resouece/collection name for the class
		def self.resource_for(classname)
			classname.db_key
		end

# accessor for @@collection_classes
		def self.collection_classes
			@collection_classes
		end

# The database accessor
		def self.dbconn
			# occasionally it'll disconnect after a query for no reason. this seems
			# decent protection.
			return @db if @db && @db.connected?
      db = ""
			conn = ""

      if mongo_url = ENV["GREYGOO_MONGO_URI"]
				db = EM::Synchrony::ConnectionPool.new(size: 1) do
					mongolab = URI.parse(mongo_url)
					conn = EM::Mongo::Connection.new mongolab.host, mongolab.port, 1
					@dbname = mongolab.path[1..-1]
					EM::Synchrony.sync conn.db(@dbname).authenticate mongolab.user, mongolab.password
					conn
				end
      else
				db = EM::Synchrony::ConnectionPool.new(size: 1) do
					conn = EM::Mongo::Connection.new('localhost')
				end
      end
      @db = db
    end

# gets the database handle
		def self.db
			return self.dbconn.db(@dbname)
		end

# Like EM::Synchrony.sync but with a timeout. not used yet.
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

# Converts an id from the database into a #GreyGoo::Id object
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

require "greygoo/player"
require "greygoo/object"
require "greygoo/base"
require 'greygoo/id'
require "greygoo/room"
require "greygoo/ability"
require "greygoo/ability/room"
require "greygoo/ability/player"
require "greygoo/ability/object"
require "greygoo/options"
require "greygoo/options/room"
require "greygoo/options/player"
require "greygoo/options/object"
