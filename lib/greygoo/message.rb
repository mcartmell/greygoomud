class GreyGoo
	class Message < GreyGoo::Common
    DB_KEY = "message"

    include GreyGoo::Role::Storable
		attr_accessor :to, :from, :text

		def read
			db_delete	
		end

	end
end
