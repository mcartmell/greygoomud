class Arml
	module Role
		module Container
			require 'set'
			attr_accessor :is_container 

			# some things have more than one container, eg. room has objects and
			# players. so default to objects and initialize the instance variable
			def objs(sym = :@objects)
				if !instance_variables.include?(sym)
					return instance_variable_set(sym, Set.new)
				end
				# bit of a hack.. try the accessor first in case it's lazily
				# initialized
				if self.respond_to?(sym[1..-1])
					return self.send(sym[1..-1])
				end
				# but otherwise just use our instance variable
				instance_variable_get(sym)
			end

# Takes the object and gives it to self unconditionally
#
# @param [Object] object The object to take, must be a Containable
			def take(object, collection_name = 'objects', *a)
				oldparent = object.parent

				# set the object's parent. this is atomic authoritative
				object.move_to(self, *a)

				# set in our objects
				sym = "@#{collection_name}".to_sym
				objs(sym) << object

				db_update({}, {'$addToSet' => { collection_name => object.id.to_db }})
				# remove from old parent
				if oldparent
					oldparent.letgo(object)
				end
			end

# Removes the object from the container. Does not put it anywhere else.
#
# @param [Object] object The object to remove
			def letgo(object, collection_name = 'objects', *a)
				return if !self.has?(object)
				sym = "@#{collection_name}".to_sym
				objs(sym).delete_if {|o| o.id.id == object.id.id}
				db_update({}, {'$pull' => { collection_name => { id: object.id.id }}})
			end

# Checks whether an object is in the container
#
# @param [Object] object The object to check
			def has?(object, collection_name = 'objects')
				sym = "@#{collection_name}".to_sym
				myobjs = objs(sym)
				return myobjs.any? {|e| e.id.id == object.id.id}
			end
		end
	end
end
