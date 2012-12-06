class GreyGoo
	class Ability
		
		@@can_map = {}

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
		
		def self.can(action, class_name = nil, &block)
			unless class_name
				class_name = @gg_class
			end
			@@can_map[class_name] ||= {}
			@@can_map[class_name][action] = { block: block }
		end

		def can?(*a)
			GreyGoo::Ability.can?(self, *a)
		end

		def self.can?(caller, action, *a)
			class_name = a[0].is_a?(Class) ? a[0] : a[0].class
			v = find_action(class_name, action) or return false
			return v[:block].call(caller, *a)
		end

		def self.find_action(classname, name)
			return false if !@@can_map.has_key?(classname)
			return @@can_map[classname][name]
		end
	end
end
