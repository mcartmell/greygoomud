require "arml"

room = Arml::Room.new
room.name = "the name"
room.description = "the description"
id = room.save
room2 = Arml::Room.load(id)
p room2
p room2.to_json
