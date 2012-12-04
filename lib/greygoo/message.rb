class GreyGoo
	class Message < GreyGoo::Common
    DB_KEY = "message"

    include GreyGoo::Role::Storable
		attr_accessor :to, :from, :text

	end
end
