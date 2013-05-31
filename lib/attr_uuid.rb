require "uuidtools"
require "attr_uuid/version"

module AttrUuid
  require "attr_uuid/railtie" if defined?(Rails)

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def attr_uuid(name)
      name = name.to_s if name.is_a?(Symbol)

      if !name.is_a?(String)
        return
      end

      define_method "formatted_#{name}" do
        binary = self.send(name)
        return UUIDTools::UUID.parse_raw(binary).to_s
      end

      define_method "formatted_#{name}=" do |value|
        uuid = UUIDTools::UUID.parse(value)
        self.send("#{name}=", uuid.raw)
      end

      define_method "hex_#{name}" do
        binary = self.send(name)
        return UUIDTools::UUID.parse_raw(binary).hexdigest
      end

      define_method "hex_#{name}=" do |value|
        uuid = UUIDTools::UUID.parse_hexdigest(value)
        self.send("#{name}=", uuid.raw)
      end
    end
  end
end
