class Arml
  class Base
    attr_reader :db

    def db_key
			self.class.db_key
    end

		def self.db_key
			const_get('DB_KEY')
		end

		def self.coll
			Arml.db.collection(db_key)
		end

    def db
      Arml.db
    end
		
# Given a hash, initialize the object
#
# @param [Hash] hash the hash to initialize from
    def set_from_hash(hash = {})
      hash.each do |k,v|
        self.send(k.to_s + '=', v)
      end
			do_coercions
    end

# Coerce any attributes (eg. ids) into objects
		def do_coercions
		end

# Constructs object from a hashref
#
# @param [Hash] hash See #set_from_hash
		def initialize(hash)
			set_from_hash(hash)
		end

  end
end
