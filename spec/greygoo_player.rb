require "greygoo"
require "greygoo/player"
require "em-synchrony"

describe GreyGoo::Player do
	it "can move into a room" do
		EM.synchrony do
			room = GreyGoo::Room.new({name: "room a", description: "test"})
			room.save!
			room2 = GreyGoo::Room.new({name: "room b", description: "test"})
			room2.save!
			player = GreyGoo::Player.new({name: "mikec", description: "hai"})
			player.save!
			player.move_to_room(room2, true)
			player.reload
			parent = player.parent
			room3 = GreyGoo.find(room2.id)
			room2.reload
			room3.to_h.should == room2.to_h
			EM.stop
		end
	end
end
