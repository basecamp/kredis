# frozen_string_literal: true

class Kredis::Types::Proxy
  require_relative "proxy/failsafe"
  include Failsafe

  attr_accessor :key

  thread_mattr_accessor :pipeline

  class << self
    def proxy_from(key, config:, after_change:, default: nil)
      new(configured_for(config), namespaced_key(key)).then do |type|
        after_change ? Kredis::CallbacksProxy.new(type, after_change) : type
      end
    end

    delegate :configured_for, :namespaced_key, to: Kredis
  end

  def initialize(redis, key, **options)
    @redis, @key = redis, key
    options.each { |key, value| send("#{key}=", value) }
  end

  def multi(*args, **kwargs, &block)
    redis.multi(*args, **kwargs) do |pipeline|
      self.pipeline = pipeline
      block.call
    ensure
      self.pipeline = nil
    end
  end

  def method_missing(method, *args, **kwargs)
    Kredis.instrument :proxy, **log_message(method, *args, **kwargs) do
      failsafe do
        redis.public_send method, key, *args, **kwargs
      end
    end
  end

  private
    def redis
      pipeline || @redis
    end

    def log_message(method, *args, **kwargs)
      args      = args.flatten.reject(&:blank?).presence
      kwargs    = kwargs.reject { |_k, v| v.blank? }.presence

      { message: "#{method.upcase} #{key} #{args&.inspect} #{kwargs&.inspect}".chomp }
    end
end
