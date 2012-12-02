require "arml"
require "em-synchrony"

describe Arml::Room do

	it "can serialize" do
		room = Arml::Room.new({name: "test room", description: "test desc"})
		room.to_h.should include({name: "test room", description: "test desc"})
	end

	it "can add exits" do
		EM.synchrony do
			room1 = Arml::Room.new({name: "room1"})
			room1.save!
			room2 = Arml::Room.new({name: "room2"})
			room2.save!
			room1.add_exit("north", room2)
			room3 = Arml::Room.load(room1._id)
			check = room3.connected_to?(room2)
			check.should == true
			EM.stop
		end
	end

	it "can save and reload" do
		EM.synchrony do
			room = Arml::Room.new({name: "test room 2", description: "test2"})
			room.save!
			id = room._id
			room2 = Arml::Room.load(id)
			room2.to_h.should == room.to_h
			EM.stop
		end
	end

	it "can convert to resource" do
		EM.synchrony do
		room = Arml::Room.new({name: "test room 3", description: "test desc"})
		room.save!
		room.to_resource.should include({name: "test room 3", description: "test desc"})
		def room.rkeys
			[:name]
		end
		room.to_resource.should include({name: "test room 3"})
		res = room.to_resource
		id = res[:id]
		# try to find by object id
		room2 = Arml.find(id)
		room2.to_h.should == room.to_h
			EM.stop
		end
	end
end
