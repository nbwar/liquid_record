require 'active_support/inflector'

class LiquidRecord
  attr_accessor :type

  @@validators = Hash.new { |h,k| h[k] = [] }
  @@type_validators = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = [] } }

  def self.validators
    @@validators
  end

  def self.validate *args, &block
    attribute = args.shift

    if args.length > 0
      args.each do |type|
        @@type_validators[type][attribute] << block
      end
    else
      @@validators[attribute] << block
    end
  end


  def self.all
    ObjectSpace.each_object(self).to_a
  end

  def self.valid? record
    @@validators.each do |attr, validators|
      validators.each do |validator|
        return false unless record.respond_to?(attr)
        return false unless validator.call(record.send(attr))
      end
    end
    @@type_validators[record.type].each do |attr, validators|
      validators.each do |validator|
        return false unless record.respond_to?(attr)
        return false unless validator.call(record.send(attr))
      end
    end

    true
  end

  def initialize type, attributes={}
    if type.is_a?(Hash)
      set_attributes(type)
    else
      self.type = type.to_sym
      set_attributes(attributes)
    end
  end

  def type= value
    define_class_method(value.to_sym)
    instance_variable_set("@type", value.to_sym)
  end

  def update attributes
    set_attributes(attributes)
  end

  def valid?
    self.class.valid?(self)
  end

  def save
    false
  end

  def method_missing method, *args, &block
    if method =~ /=$/
      var = method.to_s.delete('=')
      self.singleton_class.class_eval "attr_accessor :#{var}"
      instance_variable_set("@#{var}", *args)
    else
      super
    end
  end

  private
    def set_attributes attrs
      attrs.each do |key, value|
        set_attribute(key, value)
      end
    end

    def set_attribute method, *value
      self.singleton_class.class_eval "attr_accessor :#{method}"
      instance_variable_set("@#{method}", *value)
    end

    def define_class_method method_name
      method = method_name.to_s.pluralize.to_sym
      self.class.define_singleton_method(method) do
        ObjectSpace.each_object(self).to_a.select do |object|
          object.type == method_name
        end
      end
    end
end
