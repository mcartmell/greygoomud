require "greygoo/base"
require "greygoo/common"
require "greygoo/role/storable"
require "greygoo/role/container"
require "greygoo/role/containable"
require "greygoo/message"
require 'set'

class GreyGoo

# Represents a player in the game
  class Player < GreyGoo::Common
# Our database key
    DB_KEY = "player"

    include GreyGoo::Role::Storable
		include GreyGoo::Role::Container
		include GreyGoo::Role::Containable

		attr_accessor :messages, :notices, :current_room

		def build
			@messages ||= Set.new
			@notices ||= Set.new
		end

		def current_room
			parent
		end

		def current_room=(a)
			self.parent=(a)
		end

# @param [Int] room_id The room id to move to
		def move_to_room_id(room_id, *a)
			move_to_room(GreyGoo::Room.load(room_id), *a)
		end

# @param [GreyGoo::Room] room The room to move to
		def move_to_room(room, force = false)
			where = {}
			if force || !current_room || current_room.connected_to?(room)
				room.take(self, 'players', force)
				current_room = room
			else
				raise GreyGoo::Error, "That room isn't connected to your current room"
			end
		end

# Creates an exit from the current room to another
		def create_exit_to(direction, room)
			current_room.add_exit(direction, room)
		end

# picks up the object, if it's in the current room
		def pickup(object)
			if object.parent == current_room
				take(object)
				self.reload
			else
				raise GreyGoo::Error, "Can't take that object"
			end
		end

# drops the object, if the player has it
		def drop(object)
			raise GreyGoo::Error, "You don't have that object" if !has?(object)
			current_room.take(object)
			self.reload # because the object's parent has lost the object, not us
		end

# Does the user have any messages waiting?
		def has_messages?
			return !(messages.empty?)
		end

		def has_notices?
			return !(notices.empty?)
		end

# Send a message to another player
#
# @param [GreyGoo::Player] other_player
# @param [String] msg
		def send_to(other_player, msg)
			m = GreyGoo::Message.new({ from: self, to: other_player, text: msg })
			m.save!
			other_player.send_message(m)
		end

# Broadcast a message to a room
#
# @param [GreyGoo::Room] room
# @param [String] msg
		def broadcast_to(room, msg)
			m = GreyGoo::Message.new({ from: self, to: room, text: msg })
			m.save!
			room.broadcast(m)
		end

# Deliver a message to this player
#
# @param [GreyGoo::Message] msg
		def send_message(msg)
			db_update({}, {'$push' => { 'messages' => msg.id.to_db } })
			messages.add(msg)
		end

# Gets the messages, and also clear them in the database. Does not actually
# delete the messages yet, as they might not have been read.

		def get_messages!
			# clear messages
			msgs = messages
			db_set({}, { messages: [] })			
			messages = Set.new
			return { messages: GreyGoo.serialize(msgs) }
		end

# Converts the player to a hash. Renames parent to 'current_room'
		def to_resource
			r = super
			r["current room"] = r.delete(:parent)
			r
		end
	
		def notify(msg)
			db_update({}, {'$push' => { 'notices' => msg } })
			notices.add(msg)
		end

		def get_notices!
			notes = notices
			db_set({}, { messages: [] })			
			notices = Set.new
			return { notices: notes }
		end
  end
end
