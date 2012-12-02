require "arml"
require 'eventmachine'
require 'em-synchrony'

EM.synchrony do
	player = Arml::Player.new({})
	player.save!
	p player.id
end
