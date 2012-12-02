require "arml/base"
require "arml/common"
require "arml/role/storable"
require "arml/role/container"

class Arml
  class Room < Arml::Common
    DB_KEY = "room"
    include Arml::Role::Storable
		include Arml::Role::Container

		attr_accessor :players, :exits

# Tests if the room has a connection to another
#
# @param [Arml::Room] room The other room
# @return [Bool]
		def connected_to?(room)
			return exits.values.any? { |e| e.id == room.id }
		end

		def add_exit(direction, room)
			@exits ||= {}
			exits[direction] = room
			db_set({}, { "exits.#{direction}" => room.id.to_db })
		end

  end
end
