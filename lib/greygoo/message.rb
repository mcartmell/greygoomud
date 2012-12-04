class GreyGoo
	class Message
    DB_KEY = "player"

    include GreyGoo::Role::Storable
		attr_accessor :to, :from, :text

		def initialize(from, to, text)
			@from = from
			@to = to
			@text = text
		end

	end
end
