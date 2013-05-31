require "attr_uuid/version"
require "active_record"
require "uuidtools"

module AttrUuid
  require "attr_uuid/railtie" if defined?(Rails)

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def attr_uuid(name, options = {})
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

      if self < ActiveRecord::Base
        (class << self; self end).class_eval do
          define_method "find_by_formatted_#{name}" do |value|
            uuid = UUIDTools::UUID.parse(value)
            return self.send("find_by_#{name}", uuid.raw)
          end
        end

        if options[:autofill]
          before_create do
            value = self.send(name)
            if value.blank?
              uuid = UUIDTools::UUID.timestamp_create
              self.send("#{name}=", uuid.raw)
            end
          end
        end
      end
    end
  end
end
