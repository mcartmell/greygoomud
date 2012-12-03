require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
# An object in th game sense. Currently all objects can be picked up
  class Object < Arml::Common
    DB_KEY = "object"
    include Arml::Role::Storable
		include Arml::Role::Containable

		def drop
			if !parent.current_room
				raise Arml::Error, "Nothing to drop into"
			end
			dest = parent.current_room
			dest.take(self)
		end
	end
end
