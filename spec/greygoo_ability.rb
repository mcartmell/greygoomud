require "greygoo"
require "greygoo/ability"

describe GreyGoo::Ability do
	it "can define abilities" do
		class TestB
		end

		class TestA < GreyGoo::Ability
			abilities_for TestB
			can :foo do; true; end
		end

		GreyGoo::Ability.find_action(TestA, :foo).should be_true	

		tb = TestB.new
		tb.can?(:foo, TestA).should == true
		tb.can?(:bar, TestA).should == false
	end

end
