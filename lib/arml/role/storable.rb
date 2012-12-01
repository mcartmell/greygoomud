require "json"
require "uuid"

class Arml
  module Role
    module Storable
      module ClassMethods
				def retrieve(key)
					unless key.is_a?(BSON::ObjectId)
						key = BSON::ObjectId.from_string(key)
					end
					result = EM::Synchrony.sync coll.find_one({:_id => key})
				end

        def load(key)
          return self.new(retrieve(key))
        end
      end

			def load(key)
				self.set_from_hash(self.class.retrieve(key))
			end

      def self.included includer
        includer.extend ClassMethods
      end

			def coll
				return Arml.db.collection(db_key)
			end

      def save
        mykey = db_key
				if (_id)
					return db_update_all
				else
					return db_insert
				end
      end

			def save!
				# like save but replaces the object
				id = self.save
				self.load(id)
			end

			def handle_error(res)
				if res.is_a?(Array)
					raise res[0].new(res[1])
				end
			end

			def reload
				self.load(_id)
			end

			def db_insert
				res = EM::Synchrony.sync coll.safe_insert(to_h)
				handle_error(res)
				return res
			end

			def db_update_all
				coll.update({_id: _id}, to_h)
			end

			def db_update(where = {}, cols = {}, opts = {})
				where[:_id] = _id
				res = EM::Synchrony.sync coll.safe_update(where, cols, opts)
				handle_error(res)
				return res
			end

			def db_set(where = {}, cols = {}, opts = {})
				where[:_id] = _id
				fields = { "$set" => cols }
				res = EM::Synchrony.sync coll.safe_update(where, fields, opts)
				handle_error(res)
				return res
			end
    end
  end
end
