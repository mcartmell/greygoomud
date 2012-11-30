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

    def initialize(hash = {})
      hash.each do |k,v|
        self.send(k.to_s + '=', v)
      end
    end

  end
end
