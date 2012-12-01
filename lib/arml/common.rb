require "json"
class Arml
  class Common < Arml::Base
    attr_accessor :_id, :name, :description

# @return [BSON::ObjectId] The mongo object id
		def id
			_id
		end

# @return [Hash] A hash suitable for saving to the database
    def to_h
			hash = {}
			self.instance_variables.each do |v|
				key = v.to_sym[1..-1]
				next if key == '_id'
				value = self.instance_variable_get(v)
				if value.is_a?(Arml::Base)
					# if we have an object, store only the link to it
					value = value._id
				end
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
			return hash.keys
		end

# @return [Hash] A hash representing the api resource
		def to_resource
			hash = to_h
			hash.keep_if { |k| rkeys.include?(k) }
			hash
		end

  end
end
