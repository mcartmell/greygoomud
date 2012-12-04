require "greygoo"
require "greygoo/object"
require "em-synchrony"

describe GreyGoo::Object do
	it "can be created and given to a player" do
		EM.synchrony do
			o = GreyGoo::Object.new({name: 'test object'})
			o.save!
			p = GreyGoo::Player.new({name: 'test player'})
			r = GreyGoo::Room.new({})
			r.save!
			p.save!
			p.move_to(r)
			p.reload
			p.take(o)
			p.has?(o).should == true
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
