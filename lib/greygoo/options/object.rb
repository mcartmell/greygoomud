require "greygoo/options"
class GreyGoo
	class Options
		class Object < GreyGoo::Options
			option :examine, href: '%'
			option :take, href: '%/take', description: 'Take the object'
			option :drop, href: '%/drop', description: 'Drop the object'
		end
	end
end
