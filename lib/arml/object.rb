require "arml/base"
require "arml/common"
require "arml/role/storable"

class Arml
  class Object < Arml::Common
    DB_KEY = "object"
    include Arml::Role::Storable

  end
end
