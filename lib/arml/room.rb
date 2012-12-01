require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
  class Room < Arml::Common
    DB_KEY = "room"
    include Arml::Role::Storable
		attr_accessor :players, :objects, :exits

		def initialize(hash)
			super
			@players ||= []
			@objects ||= []
			@exits ||= {}
		end

# Tests if the room has a connection to another
#
# @param [Arml::Room] room The other room
# @return [Bool]
		def connected_to?(room)
			return exits.has_value?(room._id)
		end

  end
end
