require 'spec_helper'

describe LiquidRecord do
  let(:store) { LiquidRecord.new(:store) }
  before do
    LiquidRecord.class_variable_set :@@validators, Hash.new { |h,k| h[k] = [] }
    LiquidRecord.class_variable_set :@@type_validators, Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = [] } }
  end

  describe 'class methods' do
    let!(:store1) { LiquidRecord.new(:store) }
    let!(:store2) { LiquidRecord.new(:store) }
    let!(:event1) { LiquidRecord.new(:event) }
    let!(:event2) { LiquidRecord.new(:event) }

    before do
      ObjectSpace.garbage_collect
    end

    context 'all' do
      it "should return all LiquidRecord objects" do
        all = LiquidRecord.all
        expect(all.count).to eq 4
        expect(all).to match_array [store1, store2, event1, event2]
      end
    end

    context 'dynamic pluralize type class method' do
      it "should return all LiquidRecord objects of a certine type" do
        stores = LiquidRecord.stores
        events = LiquidRecord.events
        expect(stores.count).to eq 2
        expect(events.count).to eq 2
        expect(stores).to match_array [store1, store2]
        expect(events).to match_array [event1, event2]
      end
    end
  end

  describe 'initialization' do
    it "should support type and attributes hash" do
      store = LiquidRecord.new(:store, {name: 'Foo'})
      expect(store.type).to eq :store
      expect(store.name).to eq 'Foo'
    end

    it "should support just a hash without type" do
      store = LiquidRecord.new(type: :store, name: 'Nike')
      expect(store.type).to eq :store
      expect(store.name).to eq 'Nike'
    end
  end

  describe 'validations' do
    context 'attributes' do
      before do
        LiquidRecord.validate :name do |value|
          value.length <= 15
        end
      end

      it "should perform correct validations on attribute" do
        store.name = 'Super Long Store Name!!!!!!!!!!!!!!!'
        expect(store.valid?).to eq false
        store.name = 'short name'
        expect(store.valid?).to eq true
      end

      it "should be invalid if their is a validation but the attribute is not set" do
        event = LiquidRecord.new(:event)
        expect(event.valid?).to eq false
      end
    end

    context 'attributes and type validation' do
      before do
        LiquidRecord.validate :city, :store do |value|
          value.length >= 3
        end
      end

      it "should validate the type and attribute" do
        store.city = 'AB'
        expect(store.valid?).to eq false
        store.city = 'San Francisco'
        expect(store.valid?).to eq true
      end

      it "should not validate attribute of records not matching type" do
        event = LiquidRecord.new(:event)
        event.city = 'AB'
        expect(event.valid?).to eq true
      end

      it "should be invalid if their is a validation but the attribute is not set" do
        store = LiquidRecord.new(:store)
        expect(store.valid?).to eq false
        store.city = 'San Francisco'
        expect(store.valid?).to eq true
      end
    end
  end

  describe 'dynamic setters & getters' do
    it "should allow dynamic setters" do
      store.name = 'Nike'
      expect(store.name).to eq 'Nike'
      store.city = 'San Francisco'
      expect(store.city).to eq 'San Francisco'
    end

    it "should throw NoMethodError if attribute hasn't been set" do
      expect{store.foo}.to raise_error(NoMethodError)
    end
  end

  describe '#update' do
    it "should allow for updating attributes" do
      store = LiquidRecord.new(:store)
      store.update({ phone_number: '415‐123‐4567', website: 'http://nike.com/sf' })
      expect(store.phone_number).to eq '415‐123‐4567'
      expect(store.website).to eq 'http://nike.com/sf'
    end
  end

  describe '#save' do
    it "should return false" do
      expect(store.save).to eq false
    end
  end

end
