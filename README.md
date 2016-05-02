#LiquidRecord

LiquidRecord behaves similiar to a blend of OpenStruct and ActiveModel. You can dynamically create attributes as well as validatations.

**Ruby version**

Ruby 2.2.4

**Gem dependencies**

1. ActiveSupport
2. Rspec

##Docs

**Create a LiquidRecord**
```ruby
store = LiquidRecord.new(:store)
store = LiquidRecord.new(:store, {phone_number: '415-222-2222'})
store = LiquidRecord.new({type: :store, phone_number: '415-222-2222'})
store.name = 'Nike'
store.city = 'San Francisco'
store.update({ phone_number: '415‐123‐4567', website: 'http://nike.com/sf' })
```

**Validations**
```ruby
store = LiquidRecord.new(:store)
# Validate attribute
LiquidRecord.validate :name do |value|
  value.length <= 15
end

store.name = "A Really long long long name!!!!!!!!!!!!!!!!!!!!!!!"
store.valid?
# => false

store.name = "Short Name"
store.valid?
# => true

# Validate attribute pertaining to certain types

LiquidRecord.validate :city, :store do |value|
  value.length > 3
end
store.city = "AB"
store.valid?
# => False


event = LiquidRecord.new(:event)
event.city = "AB"
event.valid?
# => true
```

**Finders**

```ruby
LiquidRecord.new(:store)
LiquidRecord.new(:store)
LiquidRecord.new(:event)

LiquidRecord.all
# => [#<LiquidRecord:0x007fb204124680 @type=:event>, #<LiquidRecord:0x007fb20412f288 @type=:store>, #<LiquidRecord:0x007fb20413e788 @type=:store>]

LiquidRecord.events
# => [#<LiquidRecord:0x007fb204124680 @type=:event>]

LiquidRecord.stores
# => [#<LiquidRecord:0x007fb20412f288 @type=:store>, #<LiquidRecord:0x007fb20413e788 @type=:store>]

```

##Setup

Clone Repo and install dependencies

**Run the test suite**
```console
rspec spec/
```