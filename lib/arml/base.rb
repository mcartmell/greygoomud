class Arml
  class Base
    attr_reader :db

    @@db_key = ""

    def db_key
      @@db_key
    end

		def self.coll
			Arml.db.collection(@@db_key)
		end

    def db
      Arml.db
    end
		
    def set_from_hash(hash = {})
      hash.each do |k,v|
        self.send(k.to_s + '=', v)
      end
			do_coercions
    end

		def do_coercions
		end

		def initialize(hash)
			set_from_hash(hash)
		end

  end
end
