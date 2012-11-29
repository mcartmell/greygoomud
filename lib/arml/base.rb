require "redis"
module Arml
  class Base
    attr_reader :db

    @@db = nil
    @@db_key = ""

    def db_key
      @@db_key
    end

    def self.db
      return @@db if @@db
      db = ""

      if redis_url = ENV["ARML_REDIS_URL"]
        uri = URI.parse(ENV["ARML_REDIS_URL"])
        db = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      else
        db = Redis.new
      end
      @@db = db
    end

    def db
      Arml::Base.db
    end

    def initialize(hash = {})
      hash.each do |k,v|
        self.send(k.to_s + '=', v)
      end
    end

  end
end
