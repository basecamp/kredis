# frozen_string_literal: true

module Kredis::Types
  autoload :CallbacksProxy, "kredis/types/callbacks_proxy"

  TYPES = %w[ scalar string integer decimal float boolean datetime json counter cycle enum flag hash list ordered_set set slots string unique_list ]

  def proxy(key, config: :shared, after_change: nil, default: nil)
    Proxy.proxy_from(key, config: config, after_change: after_change)
  end

  TYPES.each do |type|
    define_method type do |key, **options|
      "kredis/types/#{type}".classify.constantize.type_from(key, **options)
    end
  end

  def slot(key, **options)
    Slots.type_from(key, available: 1, **options)
  end
end

require "kredis/types/proxy"
require "kredis/types/proxying"
Kredis::Types::TYPES.each do |type|
  require "kredis/types/#{type}"
end
