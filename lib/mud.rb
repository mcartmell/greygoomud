require 'sinatra/base'
require 'sinatra/synchrony'
class Mud < Sinatra::Base
  register Sinatra::Synchrony
  get '/' do
    EM::Synchrony.sleep(10)
    "Hello world!"
  end
  
  get '/foo' do
    "Not blockah"
  end
end
