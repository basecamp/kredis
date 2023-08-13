# frozen_string_literal: true

require "active_support/core_ext/class/attribute"
require "active_support/core_ext/module/delegation"
require "kredis/type_casting"
require "kredis/default_values"

class Kredis::Types::Proxying
  include Kredis::TypeCasting
  prepend Kredis::DefaultValues

  class_attribute :type_as
  class_attribute :after_change_operations, default: []

  attr_accessor :proxy, :key

  class << self
    def proxying(*commands)
      delegate(*commands, to: :proxy)
    end

    def callback_after_change_for(*methods)
      self.after_change_operations = methods
    end

    def type_from(key, config: :shared, after_change: nil, **options)
      new(configured_for(config), namespaced_key(key), **options).then do |type|
        after_change ? Kredis::CallbacksProxy.new(type, after_change) : type
      end
    end

    delegate :configured_for, :namespaced_key, to: Kredis
  end

  def initialize(redis, key, **options)
    @redis = redis
    @key = key
    @proxy = Kredis::Types::Proxy.new(redis, key)
    options.each { |key, value| send("#{key}=", value) }
  end

  def failsafe(returning: nil, &block)
    proxy.suppress_failsafe_with(returning: returning, &block)
  end

  def unproxied_redis
    # Generally, this should not be used. It's only here for the rare case where we need to
    # call Redis commands that don't reference a key and don't want to be pipelined.
    @redis
  end
end
