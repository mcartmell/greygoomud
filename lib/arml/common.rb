module Arml
  class Common < Arml::Base
    attr_accessor :id, :name, :description

    def to_h
      return {
        :id => id,
        :name => name,
        :description => description
      }
    end
  end
end
