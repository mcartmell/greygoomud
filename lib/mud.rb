require 'json'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'arml'

class Mud < Sinatra::Base
  register Sinatra::Synchrony

	set :reload_templates, false
	set :show_errors, false

	before do
		@current_player = Arml::Player.load("50ba0260b4a3494370000003")
	end

	error do
		"hai"
	end

	def user
		@current_player
	end

  def initialize
    ENV["ARML_MONGO_URI"] = ENV["MONGOLAB_URI"]
  end

	get '/look' do
		redirect('/room')
	end

	get %r{/here(/.+)?} do |match|
		redirect("/look#{match}")
	end

	get %r{/self/(/.+)?} do |match|
		redirect("/player/#{match}")
	end


  get '/' do
    EM::Synchrony.sleep(10)
    "Hello world!"
  end

	get '/room/:id' do |id|
		return Arml::Room.load(id).to_json
	end

	get '/room/:id/enter' do |id|
		redirect("/enter_room/#{id}")
	end


	get '/player/:id/enter_room' do
		raise "ffs"
	end

	get '/player/:id' do
		return Arml::Player.load(id).to_json
	end


	get '/object/:id' do
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
