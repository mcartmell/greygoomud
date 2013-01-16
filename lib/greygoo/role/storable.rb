require "json"
require "uuid"

class GreyGoo
# Mixins for GreyGoo classes
  module Role
# A module for handling the database backend methods
    module Storable
# class methods that should be exported to including classes
      module ClassMethods

# Gets the row from the database as a hash
#
# @param [Object] key Either a BSON::ObjectId or a String
# @return [Hash] The hash from the db
				def retrieve(key)
					unless key.is_a?(BSON::ObjectId)
						key = BSON::ObjectId.from_string(key)
					end
					result = GreyGoo.sync coll.find_one({:_id => key})
					return result
				end

# Loads an object by id
#
# @param [Object] key See #retrieve
# @return [GreyGoo::Base]

        def load(key)
					res = retrieve(key)
					raise GreyGoo::Error, "No such thing in db: #{key}" if !res
					classname = res.has_key?('_subtype') ? eval(res['_subtype']) : self
          return classname.new(res)
        end
      end

# Replaces the current object with the one from the database
#
# @param [Object] key See #retrieve
			def load(key)
				self.set_from_hash(self.class.retrieve(key))
				return true
			end

# Declare class methods on the including class
      def self.included includer
        includer.extend ClassMethods
      end

# Stringify as the id
			def to_s
				return _id.to_s if _id
				return ""
			end

# Retrieves the Mongo collection for this class
			def coll
				return GreyGoo.db.collection(db_key)
			end

# Upserts the current object. Updates if _id is set
      def save
        mykey = db_key
				if (_id)
					return db_update_all
				else
					return db_insert
				end
      end

# Like save, but ensures the the current object is updated from the db
			def save!
				res = self.save
				id = (res == true ? self._id : res)
				raise GreyGoo::Error, "Didn't get an id" if !id
				self.load(id)
			end

# Raises an error from the database. See mongo docs; Arrays are errors.
			def handle_error(res)
				if res.is_a?(Array)
					raise res[0].new(res[1])
				end
			end

# Reloads the object from the database
			def reload
				self.load(_id)
			end

# Serializes the object and inserts it to mongo
			def db_insert
				res = EM::Synchrony.sync coll.safe_insert(to_h('db'))
				handle_error(res)
				return res
			end

# Replaces the object in the database
			def db_update_all
				db_update({}, to_h('db'))
			end

# Updates an entire row
			def db_update(where = {}, cols = {}, opts = {})
				where[:_id] = _id
				res = EM::Synchrony.sync coll.safe_update(where, cols, opts)
				handle_error(res)
				return res
			end

# Just sets an individual column
			def db_set(where = {}, cols = {}, opts = {})
				where[:_id] = _id
				fields = { '$set' => cols }
				res = EM::Synchrony.sync coll.safe_update(where, fields, opts)
				handle_error(res)
				return res
			end
			
# Deletes the object from the database
			def db_delete(where = {})
				where[:_id] = _id
				coll.remove(where)
			end
    end
  end
end
