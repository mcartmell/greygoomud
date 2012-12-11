class GreyGoo
# Represents an Id object, useful for identifying any object
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
				raise "didn't get a bson id, got #{id.inspect}"
			end
			@key = key
			@id = id
		end

# Converts an id to a link
		def to_href
			return "#{ENV['GREYGOO_URI_PREFIX']}/#{key}/#{to_s}"
		end

		def to_resource
			return {
				href: to_href,
				id: to_s,
				rel: key
			}
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

# Coerces an id object from a database hash
		def self.from_db(hash)
			return self.new(hash["key"], hash["id"])
		end
	end
end
