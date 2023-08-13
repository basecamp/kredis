# frozen_string_literal: true

class Kredis::Types::List < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  proxying :lrange, :lrem, :lpush, :ltrim, :rpush, :exists?, :del
  callback_after_change_for :remove, :prepend, :append, :<<

  typed_as :string

  def initialize(config, key, typed: nil, default: nil)
    super
  end

  def elements
    strings_to_types(lrange(0, -1))
  end
  alias to_a elements

  def remove(*elements)
    types_to_strings(elements).each { |element| lrem 0, element }
  end

  def prepend(*elements)
    lpush types_to_strings(elements) if elements.flatten.any?
  end

  def append(*elements)
    rpush types_to_strings(elements) if elements.flatten.any?
  end
  alias << append

  def clear
    del
  end

  def last(n = nil)
    n ? lrange(-n, -1) : lrange(-1, -1).first
  end

  protected
    def set_default
      append default
    end
end
