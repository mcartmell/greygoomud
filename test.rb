require "arml"
require 'eventmachine'
require 'em-synchrony'

EM.synchrony do
room = Arml::Room.new
room.name = "the name"
room.description = "the description"
id = room.save._id
puts "got #{id}"
room2 = Arml::Room.load(id)
room2.name = "changed"
room2.save
room3 = Arml::Room.load(id)
p room3
#p room2
end
