class GreyGoo
	module Role
# A module for things that can be contained eg. objects and players
		module Containable

# Moves this thing to another thing referenced by id
			def move_to_id(dest_id)
				move_to(GreyGoo.find(dest_id))
			end

# Atomically moves the object in the backend
#
# @param dest The destination object to move to
			def move_to(dest, force = false)
				where = {}
				if !force && parent
					where = { "parent.id" => parent._id }
				end

				self.db_set(where, { parent: dest.id.to_db })
			end
		end
	end
end
