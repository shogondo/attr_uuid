# attr\_uuid

attr\_uuid makes binary uuid attribute easy to use.

## Installation

Add this line to your application's Gemfile:

    gem 'attr_uuid'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attr_uuid

## Usage

1. In a migration file, prevent generate id column and add uuid column (tinyblob).

        class CreateUsers < ActiveRecord::Migration
            def up
                create_table :users, :id => false do |t|
                    t.column :uuid, :tinyblob
                    t.string :user_name
                end
                execute "ALTER TABLE users ADD PRIMARY KEY (`uuid`(16))"
            end
            def down
                drop_table :users
            end
        end

2. Change primary\_key to uuid, and call `attr_uuid` method in a model class.  When you pass `autofill: true` to `attr_uuid`, it hooks `before_create` callback to set automatically generated uuid as 16 byte binary data to id attirbute.

        class User < ActiveRecord::Base
            self.primary_key = "uuid"
            attr_uuid :id, column_name: "uuid", autofill: true
        end

3. `attr_uuid` adds `#hex_id`, `#hex_id=`, `#formatted_id` and `#formatted_id=` to the model to refer formatted uuid.

        user = User.create(:user_name => "foo")
        user.id  #=> "3~\x05v\xCBfAQ\xA2\xE1\xE0\xFC\x04\xFB3\xD1"
        user.hex_id  #=> "337e0576cb664151a2e1e0fc04fb33d1"
        user.formatted_id  #=> "337e0576-cb66-4151-a2e1-e0fc04fb33d1"

        user.hex_id = "9f648b40fa6e11e3a3ac0800200c9a66"
        user.id  #=> "\x9Fd\x8B@\xFAn\x11\xE3\xA3\xAC\b\x00 \f\x9Af"
        user.formatted_id  #=> "9f648b40-fa6e-11e3-a3ac-0800200c9a66"


5. `attr_uuid` also adds `.find_by_hex_id` and `.find_by_formatted_id` method to retrive model from data store with an uuid string.

        User.find_by_hex_id("337e0576cb664151a2e1e0fc04fb33d1")
        User.find_by_formatted_id("337e0576-cb66-4151-a2e1-e0fc04fb33d1")

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
