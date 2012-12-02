require "json"
class Arml
  class Common < Arml::Base
    attr_accessor :_id, :name, :description, :parent

# @return [BSON::ObjectId] The mongo object id
		def db_id
			_id
		end

		def id
			Arml::Id.new(self.db_key, db_id)
		end

# @return [Hash] A hash suitable for saving to the database
		def serialize(v, type = 'resource')
			if v.is_a?(Arml::Base)
				if type == 'resource'
					return v.id.to_s
				else
					return v.id.to_db
				end
			elsif v.is_a?(Hash)
				v.each do |k,val|
					v[k] = serialize(val)
				end
				return v
			elsif v.is_a?(Set)
				v = serialize(v.to_a)
			elsif v.is_a?(Array)
				v.each_with_index do |item, i|
					v[i] = item
				end
			end
			return v
		end

		def coerce(v)
			if v.is_a?(Array)
				v = v.map{|item| coerce(item)}.to_set
			elsif v.is_a?(Hash)
				if v["id"].is_a?(BSON::ObjectId)
					arml_id = Arml::Id.from_db(v)
					v = Arml.find(arml_id)
				else
					v.each do |k,val|
						v[k] = coerce(val)
					end
				end
			end
			return v
		end

		def build
		end

# Given a hash, initialize the object
#
# @param [Hash] hash the hash to initialize from
    def set_from_hash(hash = {})
			self.build #XXX some classes NEED things to be defined. but how does this work with mixins?
      hash.each do |k,v|
				myk = k
				if !instance_variables.include?("@#{k}".to_sym)
					self.instance_variable_set("@#{k}".to_sym, nil)
				end
				self.define_singleton_method(myk.to_sym) do
						iv = self.instance_variable_get("@#{k}".to_sym)
						return iv if iv
						return self.instance_variable_set("@#{k}".to_sym, coerce(v))
				end
      end
    end

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
      to_resource.to_json(*a)
    end

# @return [Array] A list of keys that should be used to restrict the resource hash
		def rkeys
			hash = to_h
			return hash.keys.select { |k| !keys_to_exclude.include?(k) }
		end

		def keys_to_exclude
			return []
			#%w{parent}
		end

# @return [Hash] A hash representing the api resource
		def to_resource
			hash = to_h
			hash.keep_if { |k| rkeys.include?(k) }
			hash[:id] = id
			hash
		end

		def ==(object)
			to_h = object.to_h
		end


  end
end
