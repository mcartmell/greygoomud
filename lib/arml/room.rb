require "arml/base"
require "arml/common"
require "arml/role/storable"

module Arml
  class Room < Arml::Common
    include Arml::Role::Storable
    alias :orig_to_h :to_h

    def to_json(*a)
      hash = orig_to_h
      hash.update(
      {
      })
      hash.to_json(*a)
    end

    @@db_key = "room"
  end
end
