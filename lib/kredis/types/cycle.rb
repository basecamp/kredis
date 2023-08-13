# frozen_string_literal: true

class Kredis::Types::Cycle < Kredis::Types::Counter
  callback_after_change_for :next, :reset

  attr_accessor :values

  def initialize(config, key, values:, expires_in: nil)
    @values = values
    super(config, key, expires_in: expires_in)
  end

  alias index value

  def value
    values[index]
  end

  def next
    set (index + 1) % values.size
  end
end
