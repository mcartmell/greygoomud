require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
  class Player < Arml::Common
    @@db_key = "player"
    include Arml::Role::Storable

  end
end
