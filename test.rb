require "arml"
require 'eventmachine'
require 'em-synchrony'

EM.synchrony do
	room = Arml::Room.new({})
end
