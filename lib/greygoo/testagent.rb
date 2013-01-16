require 'rack/test'
require 'mud'
require 'json'

class GreyGoo
	class TestAgent
		attr_reader :browser
		attr_accessor :user_id

		def app
			Mud
		end

		def initialize
			@browser = Rack::Test::Session.new(Rack::MockSession.new(Mud))
			@browser.header('Accept', 'application/json')
			register_user
		end

		def name
			"TestBot#{object_id}"
		end

# Register a user, save their id and draw their sword
		def register_user
			res = json_get("/enter?name=#{name}")
			@browser.header('X-Authentication', res['session_key'])
			res = json_get('/self')
			@user_id = res['id']
			weapon_id = res['objects'][0]['id']
			res = json_get("/object/#{weapon_id}/wield")
		end

		%w{get put post}.each do |method|
			define_method("json_#{method}") do |url|
				browser.send(method, url)
				while browser.last_response.redirect?
					browser.follow_redirect!
				end
				JSON.parse(browser.last_response.body)
			end
		end
	end
end
