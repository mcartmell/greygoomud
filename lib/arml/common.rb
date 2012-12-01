require "json"
class Arml
  class Common < Arml::Base
    attr_accessor :_id, :name, :description

		def id
			_id
		end

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

    def to_json(*a)
      to_h.to_json(*a)
    end

		def rkeys
			hash = to_h
			return hash.keys
		end

		def to_resource
			hash = to_h
			hash.keep_if { |k| rkeys.include?(k) }
			hash
		end

  end
end
