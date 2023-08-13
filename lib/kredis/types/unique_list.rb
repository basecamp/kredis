# frozen_string_literal: true

# You'd normally call this a set, but Redis already has another data type for that
class Kredis::Types::UniqueList < Kredis::Types::List
  proxying :multi, :ltrim, :exists?
  callback_after_change_for :remove, :prepend, :append, :<<

  attr_accessor :limit

  typed_as :string

  def initialize(config, key, limit: nil, typed: nil, default: nil)
    @limit = limit
    super(config, key, typed: typed, default: default)
  end

  def prepend(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    multi do
      remove elements
      super
      ltrim 0, (limit - 1) if limit
    end
  end

  def append(elements)
    elements = Array(elements).uniq
    return if elements.empty?

    multi do
      remove elements
      super
      ltrim(-limit, -1) if limit
    end
  end
  alias << append
end
