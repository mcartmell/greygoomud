require "arml"
require "arml/object"
require "em-synchrony"

describe Arml::Object do
	it "can be created and given to a player" do
		EM.synchrony do
			o = Arml::Object.new({name: 'test object'})
			o.save!
			p = Arml::Player.new({name: 'test player'})
			r = Arml::Room.new({})
			r.save!
			p.save!
			p.move_to(r)
			p.reload
			p.take(o)
			o.reload
			o.parent.should == p
			p.has?(o).should == true
			o.drop
			o.parent.has?(o).should == false
			p.reload
			p.has?(o).should == false
			EM.stop
		end
	end
end
