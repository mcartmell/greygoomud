class Arml
	module Role
		module Container
			require 'set'
			attr_accessor :is_container 

			# some things have more than one container, eg. room has objects and
			# players. so default to objects and initialize the instance variable
			def objects(sym = :@objects)
				if !instance_variables.include?(sym)
					instance_variable_set(sym, Set.new)
				end
				return instance_variable_get(sym)
			end

			def take(object, collection_name = 'objects', *a)
				oldparent = object.parent

				# set the object's parent. this is atomic authoritative
				object.move_to(self, *a)

				# set in our objects
				sym = "@#{collection_name}".to_sym
				objects(sym) << object

				db_update({}, {'$addToSet' => { collection_name => object.id.to_db }})
				# remove from old parent
				if oldparent
					db.update({}, {'$pull' => { collection_name => object.id.to_db }})
				end
			end

			def has?(object)
				objects.include?(object)
			end
		end
	end
end
