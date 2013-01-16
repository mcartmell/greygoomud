ENV["RACK_ENV"] = 'test'

require 'mud'
require 'rspec'
require 'rack/test'
require 'greygoo/testagent'

Sinatra::Synchrony.patch_tests!

describe 'The app' do

	it "can stage combat" do
		user1 = GreyGoo::TestAgent.new
		user2 = GreyGoo::TestAgent.new
		res = user1.json_put("/player/#{user2.user_id}/attack")
		res['notices'][0].should match(/You hit/)
	end

end
