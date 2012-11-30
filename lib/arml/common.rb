require "json"
class Arml
  class Common < Arml::Base
    attr_accessor :_id, :name, :description

		def id
			_id
		end

    def to_h
      return {
        :name => name,
        :description => description
      }
    end

    def to_json(*a)
      hash = to_h
      hash.update(
      {
      })
      hash.to_json(*a)
    end

  end
end
