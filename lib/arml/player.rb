require "arml/base"
require "arml/common"
require "arml/role/storable"
require "arml/role/container"
require "arml/role/containable"

class Arml
  class Player < Arml::Common
    DB_KEY = "player"

    include Arml::Role::Storable
		include Arml::Role::Container
		include Arml::Role::Containable

		alias_method :current_room, :parent
		alias_method :current_room=, :parent=

# @param [Int] room_id The room id to move to
		def move_to_room_id(room_id, *a)
			move_to_room(Arml::Room.load(room_id), *a)
		end

# @param [Arml::Room] room The room to move to
		def move_to_room(room, force = false)
			where = {}
			if force || current_room.connected_to?(room)
				room.take(self, 'players', force)
			else
				raise Arml::Error, "That room isn't connected to your current room"
			end
		end

		def build
			self.parent = nil
		end

# picks up the object, if it's in the current room
		def pickup(object)
			if object.parent == current_room
				take(object)
			else
				raise Arml::Error, "Can't take that object"
			end
		end

# drops the object, if the player has it
		def drop(object)
			object.drop if has?(object)
		end

  end
end
