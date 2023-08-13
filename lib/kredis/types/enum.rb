# frozen_string_literal: true

require "active_support/core_ext/object/inclusion"

class Kredis::Types::Enum < Kredis::Types::Proxying
  proxying :set, :get, :del, :exists?
  callback_after_change_for :value=, :reset

  attr_accessor :values

  def initialize(config, key, values:, default:)
    super
    define_predicates_for_values
  end

  def value=(value)
    if validated_choice = value.presence_in(values)
      set validated_choice
    end
  end

  def value
    get || default
  end

  def reset
    del
  end

  private
    def define_predicates_for_values
      values.each do |defined_value|
        define_singleton_method("#{defined_value}?") { value == defined_value }
        define_singleton_method("#{defined_value}!") { self.value = defined_value }
      end
    end

    def set_default
      # default is not persisted
    end
end
