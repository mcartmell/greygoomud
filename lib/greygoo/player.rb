require "greygoo/base"
require "greygoo/common"
require "greygoo/role/storable"
require "greygoo/role/container"
require "greygoo/role/containable"

class GreyGoo

# Represents a player in the game
  class Player < GreyGoo::Common
    DB_KEY = "player"

    include GreyGoo::Role::Storable
		include GreyGoo::Role::Container
		include GreyGoo::Role::Containable

		#alias_method :current_room, :parent
		#alias_method :current_room=, :parent=

		def current_room
			parent
		end

		def current_room=(a)
			self.parent=(a)
		end

# @param [Int] room_id The room id to move to
		def move_to_room_id(room_id, *a)
			move_to_room(GreyGoo::Room.load(room_id), *a)
		end

# @param [GreyGoo::Room] room The room to move to
		def move_to_room(room, force = false)
			where = {}
			if force || !current_room || current_room.connected_to?(room)
				room.take(self, 'players', force)
				current_room = room
			else
				raise GreyGoo::Error, "That room isn't connected to your current room"
			end
		end

		def create_exit_to(direction, room)
			current_room.add_exit(direction, room)
		end

# picks up the object, if it's in the current room
		def pickup(object)
			if object.parent == current_room
				take(object)
				self.reload
			else
				raise GreyGoo::Error, "Can't take that object"
			end
		end

# drops the object, if the player has it
		def drop(object)
			raise GreyGoo::Error, "You don't have that object" if !has?(object)
			current_room.take(object)
			self.reload # because the object's parent has lost the object, not us
		end

  end
end
