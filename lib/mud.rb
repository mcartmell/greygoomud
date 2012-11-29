require 'sinatra/base'
require 'sinatra/synchrony'
require 'redis'
require 'redis/connection/synchrony'

class Mud < Sinatra::Base
  register Sinatra::Synchrony
  attr_reader :redis_url

  def initialize
    @redis_url = ENV["REDISTOGO_URL"]
    super
  end


  get '/' do
    EM::Synchrony.sleep(10)
    "Hello world!"
  end
  
  get '/foo' do
    redis_url
  end
end
