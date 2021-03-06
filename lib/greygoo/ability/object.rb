require "greygoo/object"
class GreyGoo
	class Ability
		# Abilities for objects
		class Object < GreyGoo::Ability
			abilities_for GreyGoo::Player

			can :examine do |player, object|
				(player.current_room == object.parent) || player.has?(object)
			end

			can :take do |player, object|
				#p object.parent
				#p player.current_room
				player.current_room.==(object.parent)
			end

			can :drop do |player, object|
				player.has?(object)	
			end

			can :create do |player|
				true
			end

			class Weapon < GreyGoo::Ability
				can :wield do |player, object|
					player.has?(object)
				end
			end
		end
	end
end
