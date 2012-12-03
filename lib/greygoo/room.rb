require "greygoo/base"
require "greygoo/common"
require "greygoo/role/storable"
require "greygoo/role/container"

class GreyGoo
# Represents a room in the game
  class Room < GreyGoo::Common
    DB_KEY = "room"
    include GreyGoo::Role::Storable
		include GreyGoo::Role::Container

		attr_accessor :players, :exits

		def build
			@exits ||= {}
		end
# Tests if the room has a connection to another
#
# @param [GreyGoo::Room] room The other room
# @return [Bool]
		def connected_to?(room)
			return exits.values.any? { |e| e.id == room.id }
		end

# Adds a one-way exit to another room
#
# @param [String] direction A key representing the direction of the exit
# @param [GreyGoo::Room] room The room to connect to
		def add_exit(direction, room)
			exits[direction] = room
			db_set({}, { "exits.#{direction}" => room.id.to_db })
		end

  end
end
