require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
  class Object < Arml::Common
    @@db_key = "object"
    include Arml::Role::Storable

  end
end
