require "greygoo/options"
class GreyGoo
	class Options
	# Options for rooms
		class Room < GreyGoo::Options

			option :enter, href: '%', description: 'Enter the room'

			option :create_exit,
					href: '%/create_exit',
				description: "Create an exit on this room",
				method: "PUT",
				parameters: {
					direction: {
						type: 'String',
						description: 'The direction you wish to create the exit on'
					},
					name: {
						type: 'String',
						description: 'The name of the new room'
					},
					description: {
						type: 'String',
						description: 'The description of the new room'
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
