require "json"
require "uuid"

class Arml
  module Role
    module Storable
      module ClassMethods
        def load(key)
					unless key.is_a?(BSON::ObjectId)
						key = BSON::ObjectId.from_string(key)
					end
					result = EM::Synchrony.sync coll.find_one({:_id => key})
					p result
          return self.new(result)
        end
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
					return db_update
				else
					return db_insert
				end
      end

			def db_insert
				newid = coll.insert(to_h)
				return Arml::Room.load(newid)
			end

			def db_update
				coll.update({_id: _id}, to_h)
			end
    end
  end
end
