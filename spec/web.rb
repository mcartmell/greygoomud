ENV["RACK_ENV"] = 'test'

require 'mud'
require 'rack/test'

Sinatra::Synchrony.patch_tests!

describe 'The app' do
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end

	it "works" do
		get '/foo'
		last_response.status.should == 404
	end



end
