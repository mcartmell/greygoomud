class Arml
	module Role
		module Containable
			def move_to_id(dest_id)
				move_to(Arml.find(dest_id))
			end

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
