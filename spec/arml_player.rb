require "arml"
require "arml/player"
require "em-synchrony"

describe Arml::Player do
	it "can move into a room" do
		EM.synchrony do
			room = Arml::Room.new({name: "room a", description: "test"})
			room.save!
			room2 = Arml::Room.new({name: "room b", description: "test"})
			room2.save!
			player = Arml::Player.new({name: "mikec", description: "hai"})
			player.save!
			p room2
			player.move_to_room(room2, true)
			player.reload
			parent = player.parent
			room3 = Arml.find(room2.id)
			room2.reload
			room3.to_h.should == room2.to_h
			EM.stop
		end
	end
end
