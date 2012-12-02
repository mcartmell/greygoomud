require 'json'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'sinatra/json'
require 'arml'

class Mud < Sinatra::Base
	class Error < Arml::Error
	end

  register Sinatra::Synchrony
	helpers Sinatra::JSON

	set :reload_templates, false
	set :show_exceptions, false
	set :json_encoder, :to_json

	def player
		@current_player
	end

	before do
		ENV["ARML_URI_PREFIX"] = "http://#{request.host_with_port}"
		@current_player = Arml::Player.load("50bb7953b4a3490239000002")
	end

	error Arml::Error do
		errmsg = env['sinatra.error']
		errmsg.message
	end

	error do
		errmsg = env['sinatra.error']
		errmsg.message
	end

	def toj(thing)
		json thing
	end

	def user
		@current_player
	end

  def initialize
    ENV["ARML_MONGO_URI"] = ENV["MONGOLAB_URI"]
  end

	def find(id)
		id = Arml::Id.from_string(id)
		return Arml.find(id)
	end

	get '/look' do
		redirect("/room/#{player.current_room.id}")
	end

	get %r{/here(/.+)?} do |match|
		redirect("/look#{match}")
	end

	get %r{/self(/.+)?} do |match|
		redirect("/player/#{player.id}#{match}")
	end


  get '/' do
    EM::Synchrony.sleep(10)
    "Hello world!"
  end

	get '/room/:id' do |id|
		room = find(id)
		cr = player.current_room

		if (cr != room && !cr.connected_to?(room))
			raise Mud::Error, "You don't know about that room"
		end
		if (cr != room)
			player.move_to_room(room)
		end
		return toj room
	end

	get '/room/:id/enter' do |id|
		redirect("/enter_room/#{id}")
	end


	get '/player/:id/enter_room' do
		room_id = params[:room_id] or raise Mud::Error, "Need a room id"
		if params[:id] != player.id
			raise Mud::Error, "You are not that user"
		end
		player.move_to_room_id(room_id)
		return find(room_id).to_json
	end

	get '/player/:id' do |id|
		return toj find(id)
	end


	get '/object/:id' do |id|
		return Arml::Object.load(id).to_json
	end
  
  get '/create' do
		puts "here\n"
    key = Arml::Room.new({ name: "one", description: "desc" }).save
    return key._id.to_s
  end

  get '/load/:id' do |id|
    room = Arml::Room.load(id)
    room.to_json
  end


end
