require 'json'
require 'sinatra/base'
require 'sinatra/synchrony'
require 'redis'
require 'redis/connection/synchrony'
require 'arml'

class Mud < Sinatra::Base
  register Sinatra::Synchrony

  def initialize
    ENV["ARML_REDIS_URL"] = ENV["REDISTOGO_URL"]
  end


  get '/' do
    EM::Synchrony.sleep(10)
    "Hello world!"
  end
  
#  get '/foo' do
#    "hai"
#  end

  get '/create' do
    key = Arml::Room.new({ name: "one", description: "desc" }).save
    key
  end

  get '/load/:id' do |id|
    room = Arml::Room.load(id)
    room.to_json
  end
end
