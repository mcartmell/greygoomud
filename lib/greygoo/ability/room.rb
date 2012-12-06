class GreyGoo
	class Ability
		# Actions that can be performed on rooms
		class Room < GreyGoo::Ability
			abilities_for GreyGoo::Player

			can :enter do |player, room|
				(!player.current_room || player.current_room.connected_to?(room))	
			end

			can :create_exit do |player, room|
				player.current_room == room
			end

			can :create_object do |player, room|
				true
			end

			can :broadcast do |player, room|
				player.current_room == room
			end

			can :create do |player|
				true
			end
		end
	end
end
