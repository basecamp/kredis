# frozen_string_literal: true

class Kredis::Types::CallbacksProxy
  attr_reader :type
  delegate :to_s, to: :type

  def initialize(type, callback)
    @type, @callback = type, callback
  end

  def method_missing(method, *args, **kwargs, &block)
    result = type.send(method, *args, **kwargs, &block)
    invoke_suitable_after_change_callback_for method
    result
  end

  private
    def invoke_suitable_after_change_callback_for(method)
      @callback.call(type) if type.after_change_operations.include? method
    end
end
