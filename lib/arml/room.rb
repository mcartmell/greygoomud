require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
  class Room < Arml::Common
    @@db_key = "room"
    include Arml::Role::Storable
		attr_accessor :players, :objects, :exits

		def initialize(hash)
			super
			@players ||= []
			@objects ||= []
			@exits ||= {}
		end

		def connected_to?(room)
			return exits.has_value?(room._id)
		end

  end
end
