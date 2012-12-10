class GreyGoo
	class Object
		class Weapon < GreyGoo::Object
			attr_accessor :speed, :damage

			def build
				@speed = 3
				@damage = 5
				@_subtype = 'GreyGoo::Object::Weapon'
			end
		end
	end
end
