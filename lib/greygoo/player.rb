require "greygoo/base"
require "greygoo/common"
require "greygoo/role/storable"
require "greygoo/role/container"
require "greygoo/role/containable"
require "greygoo/message"
require 'set'
require 'uuid'

class GreyGoo

# Represents a player in the game
  class Player < GreyGoo::Common
# Our database key
    DB_KEY = "player"

    include GreyGoo::Role::Storable
		include GreyGoo::Role::Container
		include GreyGoo::Role::Containable

		attr_accessor :messages, :notices, :current_room, :hit_points, :weapon, :_api_key, :_session_key

		def self.find_by_session(key)
			result = GreyGoo.sync coll.find_one({:_session_key => key})
			return if !result
			if result
				return self.load(result['_id'])
			end
		end

		def build
			@messages ||= Set.new
			@notices ||= Set.new
			@hit_points = 10
		end

		def post_build
			uuid = UUID.new
			self._api_key ||= uuid.generate
			# for now, allow login just with session key. eventually users should
			# request token from the api key
			self._session_key ||= uuid.generate
		end

		def is_armed?
			self.weapon
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
			return { messages: msgs }
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
			db_set({}, { notices: [] })			
			notices = Set.new
			return { notices: notes }
		end

		def wield(w)
			raise "You don't have that weapon" unless has?(w)
			self.weapon = w
		end

		def attack(other_player)
			raise "You have nothing to attack with" unless is_armed?
			EM::Synchrony.sleep(weapon.speed)
			dmg = weapon.damage
			other_player.take_damage(dmg)
			other_player.notify("You have been hit by #{name} for #{dmg} damage")
			notify("You hit #{other_player.name} for #{dmg} damage")
		end

		def take_damage(dmg)
			self.hit_points = self.hit_points - dmg
			save
			if dead?
				die
			end
		end

		def die
			notify("You have died")
			respawn
		end

		def respawn
			hit_points = 10
			save
		end

		def dead?
			hit_points < 0
		end
  end

end
