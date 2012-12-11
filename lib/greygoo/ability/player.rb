require "greygoo/ability"

class GreyGoo
	class Ability
		# Abilities for players
		class Player < GreyGoo::Ability
			abilities_for GreyGoo::Player

			can :message do |p1, p2|
				true
			end

			can :attack do |p1, p2|
				p1 != p2 && p1.current_room == p2.current_room && p1.is_armed?
			end
		end
	end
end
