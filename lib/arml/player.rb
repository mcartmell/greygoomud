require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
  class Player < Arml::Common
    @@db_key = "player"
    include Arml::Role::Storable

		attr_accessor :current_room

		def move_to_room_id(room_id, *a)
			move_to_room(Arml::Room.load(room_id), *a)
		end

		def move_to_room(room, force = false)
			where = {}
			if !force
				where = { current_room: current_room._id }
			end
			if force || current_room.connected_to?(room)
				self.db_set(where, { current_room: room._id })
			end
		end

		def do_coercions
			# coerce
			@current_room = current_room ? Arml::Room.load(current_room) : nil
		end

  end
end
