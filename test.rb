require "arml"
require 'eventmachine'
require 'em-synchrony'

EM.synchrony do
	r = Arml.find_s('room-50bb7953b4a3490239000001')
	r2 = Arml::Room.new({name: 'The other room'})
	r2.save!
	r.add_exit("north", r2)
	r2.add_exit("south", r)
	EM.stop
end
