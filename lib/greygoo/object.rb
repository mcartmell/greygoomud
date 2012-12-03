require "greygoo/base"
require "greygoo/common"
require "greygoo/role/storable"

class GreyGoo
# An object in th game sense. Currently all objects can be picked up
  class Object < GreyGoo::Common
    DB_KEY = "object"
    include GreyGoo::Role::Storable
		include GreyGoo::Role::Containable

		def drop
			if !parent.current_room
				raise GreyGoo::Error, "Nothing to drop into"
			end
			dest = parent.current_room
			dest.take(self)
		end
	end
end
