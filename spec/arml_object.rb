require "arml"
require "arml/object"
require "em-synchrony"

describe Arml::Object do
	it "can be created" do
		EM.synchrony do
			o = Arml::Object.new({name: 'test object'})
			o.save
			p = Arml::Player.new({name: 'test player'})
			p.save
			p.take(o)
			p.has?(o).should == true
			EM.stop
		end
	end
end
