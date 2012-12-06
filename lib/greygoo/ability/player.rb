require "greygoo/ability"

class GreyGoo
	class Ability
		# Abilities for players
		class Player < GreyGoo::Ability
			abilities_for GreyGoo::Player

			can :message do |p1, p2|
				true
			end
		end
	end
end
