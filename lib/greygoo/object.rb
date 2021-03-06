require "greygoo/base"
require "greygoo/common"
require "greygoo/role/storable"

class GreyGoo
# An object in th game sense. Currently all objects can be picked up
  class Object < GreyGoo::Common
		# The collection name
    DB_KEY = "object"
    include GreyGoo::Role::Storable
		include GreyGoo::Role::Containable

		# Checks whether a player can drop this object
		def drop
			if !parent.can?(:drop, self)
				raise GreyGoo::PermissionsError, "Nothing to drop into"
			end
			dest = parent.current_room
			dest.take(self)
		end
	end
end

