class GreyGoo
	# Represents a message. Messages can be sent to users or rooms
	class Message < GreyGoo::Common
		# The collection name
    DB_KEY = "message"

    include GreyGoo::Role::Storable
		attr_accessor :to, :from, :text

		# Delete the message on read. This might change
		def read
			db_delete	
		end

	end
end
