class GreyGoo
# Defines which abilities can be called on this object by a player. Kind of
# like CanCan, except the receiving objects are defining their abilities,
# not the player
	class Ability
		
# The map of abilities
		@@can_map = {}

# Define the can? instance method for the calling class. Should always be a Player.
		def self.abilities_for(cn)
			cn.send(:define_method, :can?) do |*a|
				GreyGoo::Ability.can?(self, *a)
			end
		end

# Automatically work out which GreyGoo::Class the ability class correspon#ds to, and remember it for shortcuts 
		def self.inherited(by)
			cname = by.to_s.gsub(/::Ability/, '')
			by.instance_variable_set(:@gg_class, eval(cname))
		end
		
# Declares an ability
#
# @param [Symbol] action The action to define ability for
# @param [Class] class_name The class is handling the ability
# @param [Proc] block The code to call to check the permission. Should take two args: the calling object attempting the request (eg. the player) and the object receiving the request. If the action is on the resource and not an instance, then the proc should take one or no arguments.
		def self.can(action, class_name = nil, &block)
			unless class_name
				class_name = @gg_class
			end
			@@can_map[class_name] ||= {}
			@@can_map[class_name][action] = { block: block }
		end

#XXX is this needed?
		def can?(*a)
			GreyGoo::Ability.can?(self, *a)
		end

# Checks whether a calling object can perform an action on another object or objects
#
# @param [Object] caller
# @param [Symbol] action
		def self.can?(caller, action, *a)
			class_name = a[0].is_a?(Class) ? a[0] : a[0].class
			v = find_action(class_name, action) or return false
			return v[:block].call(caller, *a)
		end

# Checks if an action has been defined for a class
#
# @param [Class] classname
# @param [Symbol] name
		def self.find_action(classname, name)
			return false if !@@can_map.has_key?(classname)
			return @@can_map[classname][name]
		end
	end
end
