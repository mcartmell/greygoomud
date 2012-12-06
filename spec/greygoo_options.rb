require "greygoo"
require "greygoo/options"

describe GreyGoo::Options do
	it "can define options" do
		class GreyGoo
			class << self
				alias :rf :resource_for
				alias :cc :collection_to_class
			end
			def self.resource_for(thing)
				return rf(thing)
				rescue
					'testb'
			end
			def self.collection_to_class(thing)
				return cc(thing) || TestB
			end
		end

		class TestA
		end

		class TestB
		end

		class TestAbility < GreyGoo::Ability
			abilities_for TestA
			can :foo, TestB do |p|
				true
			end
		end

		class TestOptions < GreyGoo::Options
			option TestB, :foo, description: "blah"
		end

		GreyGoo::Options.get_options_for('testb', TestA.new).should eql [{class_name: TestB, action: :foo, description: 'blah', arity: 0 }]
	end
end
