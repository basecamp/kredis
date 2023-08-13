# frozen_string_literal: true

class Kredis::Types::Scalar < Kredis::Types::Proxying
  typed_as :string

  proxying :set, :get, :exists?, :del, :expire, :expireat
  callback_after_change_for :value=, :clear

  attr_accessor :expires_in

  def initialize(config, key, typed: nil, default: nil, expires_in: nil)
    super
  end

  def value=(value)
    set type_to_string(value), ex: expires_in
  end

  def value
    value_after_casting = string_to_type(get)

    if value_after_casting.nil?
      default
    else
      value_after_casting
    end
  end

  def to_s
    get || default&.to_s
  end

  def assigned?
    exists?
  end

  def clear
    del
  end

  def expire_in(seconds)
    expire seconds.to_i
  end

  def expire_at(datetime)
    expireat datetime.to_i
  end

  private
    def set_default
      self.value = default
    end
end
