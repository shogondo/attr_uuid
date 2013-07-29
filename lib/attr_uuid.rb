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
      column_name = (options[:column_name] || name)
      column_name = column_name.to_s if column_name.is_a?(Symbol)

      if !name.is_a?(String) || !column_name.is_a?(String)
        return
      end

      define_method "formatted_#{name}" do
        binary = self.send(column_name)
        if binary.nil?
          return nil
        else
          return UUIDTools::UUID.parse_raw(binary).to_s
        end
      end

      define_method "formatted_#{name}=" do |value|
        uuid = UUIDTools::UUID.parse(value)
        self.send("#{column_name}=", uuid.raw)
      end

      define_method "hex_#{name}" do
        binary = self.send(column_name)
        if binary.nil?
          return nil
        else
          return UUIDTools::UUID.parse_raw(binary).hexdigest
        end
      end

      define_method "hex_#{name}=" do |value|
        uuid = UUIDTools::UUID.parse_hexdigest(value)
        self.send("#{column_name}=", uuid.raw)
      end

      if self < ActiveRecord::Base
        (class << self; self end).class_eval do
          define_method "find_by_formatted_#{name}" do |value|
            begin
              uuid = UUIDTools::UUID.parse(value)
              return self.send("find_by_#{column_name}", uuid.raw)
            rescue
              return nil
            end
          end
          define_method "find_by_hex_#{name}" do |value|
            begin
              uuid = UUIDTools::UUID.parse_hexdigest(value)
              return self.send("find_by_#{column_name}", uuid.raw)
            rescue
              return nil
            end
          end
        end

        if options[:autofill]
          before_create do
            value = self.send(column_name)
            if value.blank?
              uuid = UUIDTools::UUID.timestamp_create
              self.send("#{column_name}=", uuid.raw)
            end
          end
        end
      end
    end
  end
end
