# frozen_string_literal: true

class Kredis::Types::Counter < Kredis::Types::Proxying
  proxying :multi, :set, :incrby, :decrby, :get, :del, :exists?
  callback_after_change_for :increment, :decrement, :reset

  attr_accessor :expires_in

  def initialize(config, key, expires_in: nil, default: 0)
    super
  end

  def increment(by: 1)
    multi do
      set_default
      incrby by
    end[-1]
  end

  def decrement(by: 1)
    multi do
      set_default
      decrby by
    end[-1]
  end

  def value
    get.to_i
  end

  def reset
    del
  end

  private
    def set_default
      set default, ex: expires_in, nx: true
    end
end
