require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
  class Room < Arml::Common
    @@db_key = "room"
    include Arml::Role::Storable

  end
end