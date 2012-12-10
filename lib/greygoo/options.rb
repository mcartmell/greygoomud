require "greygoo/ability"

class GreyGoo
# Describe options for GreyGoo entities
	class Options
		@@opts = {}

# Define an option for a class
#
# @param [Class] classname The thing to define an option for
# @param [Symbol] action The name of the action to define options for
		def self.option(classname = nil, action, opts)
			classname ||= @options_for
			can_spec = GreyGoo::Ability.find_action(classname, action)
			raise "Couldn't find a matching ability for #{action} on #{classname}" unless can_spec
			arity = 0
			arity = can_spec[:block].arity - 1 if can_spec.has_key?(:block)
			arity = 0 if arity < 0 # arity 0 makes no sense - it has to have another class to perform the action on
			opts.update(arity: arity, class_name: classname, action: action)
			@@opts[classname] ||= []
			@@opts[classname].push(opts)
		end

# Work out the name of the corresponding class automatically
		def self.inherited(by)
			cname = by.to_s.gsub(/::Options/, '')
			by.instance_variable_set(:@options_for, eval(cname))
		end

		def self.valid_opts(classname)
			return classname.ancestors.map {|e| @@opts[e]}.flatten.compact
		end

# options_for(GreyGoo::Room, player, room_object)
# options_for(GreyGoo::Room, player)
		def self.get_options_for(classname, player, *a)
			a_size = a.size
			if a.empty?
			 a = [classname]
			end
			return [] if !valid_opts = self.valid_opts(classname)
			# first, limit by arity (the things applying to 0 objects, 1 objects, 2 objects etc.)
			# creates a new reference so we don't override the resource
			valid_opts = valid_opts.select {|e| e[:arity] == a_size}
			# then limit by those the player can do
			valid_opts.select! {|e| player.can?(e[:action], *a) }
			
			unless a[0].is_a?(Class)
				ids = a.map { |e| e.id }
				valid_opts = valid_opts.map { |e| e.clone }
				# finally, work out the href automatically
				valid_opts.each do |e|
					sub = 0
					e[:href].gsub!(%r{%}) do 
						next_id = ids[sub]
						thing_to_sub = sub == 0 ? next_id.to_href : next_id.to_s
						sub += 1
						thing_to_sub
					end
					e.delete(:arity)
					e.delete(:class_name)
				end
			end

			return valid_opts
		end

	end
end
