require "arml"
require "em-synchrony"

describe Arml::Room do
	it "can serialize" do
		room = Arml::Room.new({name: "test room", description: "test desc"})
		room.to_h.should include({name: "test room", description: "test desc"})
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
		room = Arml::Room.new({name: "test room 3", description: "test desc"})
		room.to_resource.should include({name: "test room 3", description: "test desc"})
		def room.rkeys
			[:name]
		end

		room.to_resource.should == {name: "test room 3"}
	end
end
