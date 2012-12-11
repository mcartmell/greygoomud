require "greygoo/options"
class GreyGoo
	class Options
# Options for Player objects
		class Player < GreyGoo::Options
			option :message, href: '%/message',
				method: "POST",
				description: "Message this user",
				parameters: {
					message: {
						type: 'String',
						description: 'The text of the message you want to send'
					}
				}

			option :attack, href: '%/attack',
				method: "PUT",
				description: "Attack this user"
					
		end
	end
end
