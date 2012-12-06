require "json"
class GreyGoo
# The base class for all entities (should be renamed really)
  class Common < GreyGoo::Base
    attr_accessor :_id, :name, :description, :parent

# @return [BSON::ObjectId] The mongo object id
		def db_id
			_id
		end

# The id of this object
		def id
			GreyGoo::Id.new(self.db_key, db_id)
		end

# Serializes the object for storage or serving to a client
		def serialize(*a)
			return GreyGoo.serialize(*a)
		end

# Coerces an object from a database row
		def coerce(v)
			return GreyGoo.coerce(v)
		end

# Should be overridden
		def build
		end

# Given a hash, initialize the object
#
# @param [Hash] hash the hash to initialize from
    def set_from_hash(hash = {})
			self.build
      hash.each do |k,v|
				myk = k
				# set to nil so that any previous values get overridden by the
				# accessor. classes should use initialize() if they want different
				# behaviour
				self.instance_variable_set("@#{k}".to_sym, nil)
				self.define_singleton_method(myk.to_sym) do
						iv = self.instance_variable_get("@#{k}".to_sym)
						return iv if iv
						return self.instance_variable_set("@#{k}".to_sym, coerce(v))
				end
      end
    end

# Attempts to serialize the class by finding any accessors and serializing
# their values.
    def to_h(type = 'resource')
			hash = {}
			self.instance_variables.each do |v|
				key = v.to_sym[1..-1]
				next if key == '_id'
				next if !self.respond_to?(key.to_s)
				value = self.send(key)
				value = serialize(value, type)
				hash[key.to_sym] = value
			end
			return hash
    end

# @return [String] A json representation of the resource
    def to_json(*a)
      JSON.pretty_generate(to_resource)
    end

# @return [Array] A list of keys that should be used to restrict the resource hash
		def rkeys
			hash = to_h
			return hash.keys.select { |k| !keys_to_exclude.include?(k) }
		end

# Unused
		def keys_to_exclude
			return []
		end

# @return [Hash] A hash representing the api resource
		def to_resource
			hash = to_h
			hash.keep_if { |k| rkeys.include?(k) }
			hash[:id] = id
			hash[:href] = id.to_href
			hash
		end

# Compares equality by comparing the ids
		def ==(object)
			id == object.id
		end

# Clones the object by returning a new copy from the database
		def clone
			return GreyGoo.find(self.id)
		end


  end
end
