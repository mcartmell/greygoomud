class Arml
	module Role
		module Container
			require 'set'
			attr_accessor :is_container 

			def build
				@objects = Set.new
			end

			def objects
				@objects
			end

			def take(object, collection_name = 'objects', *a)
				oldparent = object.parent

				# set the object's parent. this is atomic authoritative
				object.move_to(self, *a)
				# set in our objects

				self.objects << object
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
