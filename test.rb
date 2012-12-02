require "arml"
require 'eventmachine'
require 'em-synchrony'

EM.synchrony do
	player = Arml::Player.new({ name: "mike-c" })
	room = Arml::Room.new({ name: "The entrance hall" })
	room.save!
	player.save!
	player.move_to_room(room)
	p player.id
end
