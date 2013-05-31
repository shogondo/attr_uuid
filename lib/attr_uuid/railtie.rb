require "attr_uuid"

module AttrUuid
  class Railtie < Rails::Railtie
    initializer "activerecord_uuid_as_pk.initialize" do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, AttrUuid
      end
    end
  end
end
