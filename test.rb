require "arml"
require 'eventmachine'
require 'em-synchrony'

EM.synchrony do
	r = Arml.find_s('room-50bb7953b4a3490239000001')
	o = Arml::Object.new({name: 'A ball'})
	o.save!
	r.take(o)
	EM.stop
end
