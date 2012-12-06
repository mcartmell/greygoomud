require "greygoo/options"
class GreyGoo
	class Options
	# Options for rooms
		class Room < GreyGoo::Options

			option :enter, href: '%', description: 'Enter the room'

			option :create_exit,
					href: '%/create_exit',
				description: "Link this room with another",
				method: "PUT",
				parameters: {
					direction: {
						type: 'String',
						description: 'The direction you wish to create the exit on'
					},
					to: {
						type: 'String',
						description: 'The identifier of the room you want to link to'
					}
				}

			option :create_object,
				href: '%/create_object',
				method: "POST",
				description: "Create a new object in this room",
				parameters: {
					name: {
						type: 'String',
						description: 'The name of the object to create'
					},
					description: {
						type: 'String',
						description: "The object's description"
					}
				}

			option :broadcast,
				href: '%/broadcast',
				method: "POST",
				description: "Send a broadcast message to this room",
				parameters: {
					message: {
						type: 'String',
						description: 'The text of the message you want to send'
					}
				}

			option :create,
				href: '/room',
				method: 'POST',
				description: 'Create a new room',
				parameters: {
					name: {
						type: 'String',
						description: 'The name of the room to create'
					},
					description: {
						type: 'String',
						description: 'A description of the room'
					}
				}
			
		end
	end
end
