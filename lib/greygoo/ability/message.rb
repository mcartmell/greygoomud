class GreyGoo
	class Ability
		# Abilities for messages
		class Message < GreyGoo::Ability
			ability_for GreyGoo::Player

			can :read do |p, m|
				(m.from == p || m.to == p)
			end
		end
	end
end
