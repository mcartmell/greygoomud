require "json"
require "uuid"

module Arml
  module Role
    module Storable
      module ClassMethods
        def load(key)
          json = db.get(key)
          hash = JSON.parse(json)
          return self.new(hash)
        end
      end
      def self.included includer
        includer.extend ClassMethods
      end

      def key
        id = self.id || UUID.new.generate
        return "#{name}-#{id}".gsub(/[- ]/, '_')
      end


      def save
        mykey = key
        db.set(mykey, to_json)
        return mykey
      end
    end
  end
end
