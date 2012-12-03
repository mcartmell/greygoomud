require "arml"

class Arml
# Base class for all objects
  class Base
    attr_reader :db
		alias :old_to_s :to_s

    def db_key
			self.class.db_key
    end

		def self.db_key
			const_get('DB_KEY')
		end

		def self.coll
			Arml.db.collection(db_key)
		end

		def self.inherited(base)
			Arml.collection_classes.push(base)
		end

    def db
      Arml.db
    end
		
# Constructs object from a hashref
#
# @param [Hash] hash See #set_from_hash
		def initialize(hash)
			set_from_hash(hash)
		end

		def inspect
			old_to_s
		end

  end
end
