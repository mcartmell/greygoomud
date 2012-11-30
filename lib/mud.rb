require 'json'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'arml'

class Mud < Sinatra::Base
  register Sinatra::Synchrony

  def initialize
    ENV["ARML_MONGO_URL"] = ENV["MONGOLAB_URI"]
  end


  get '/' do
    EM::Synchrony.sleep(10)
    "Hello world!"
  end
  
  get '/create' do
    key = Arml::Room.new({ name: "one", description: "desc" }).save
    key.inspect
  end

  get '/load/:id' do |id|
    room = Arml::Room.load(id)
    room.to_json
  end
end
