require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
  class Player < Arml::Common
    DB_KEY = "player"

    include Arml::Role::Storable

		attr_accessor :current_room

# @param [Int] room_id The room id to move to
		def move_to_room_id(room_id, *a)
			puts "FFFFSSSSS"
			move_to_room(Arml::Room.load(room_id), *a)
		end

# @param [Arml::Room] room The room to move to
		def move_to_room(room, force = false)
			where = {}
			if !force
				where = { current_room: current_room._id }
			end
			if force || current_room.connected_to?(room)
				self.db_set(where, { current_room: room._id })
			else
				raise Arml::Error, "That room isn't connected to your current room"
			end
		end

		def do_coercions
			# coerce
			@current_room = current_room ? Arml::Room.load(current_room) : nil
		end

  end
end
