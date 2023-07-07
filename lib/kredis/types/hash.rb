require "active_support/core_ext/hash"

class Kredis::Types::Hash < Kredis::Types::Proxying
  proxying :hget, :hset, :hmget, :hdel, :hgetall, :hkeys, :hvals, :del, :exists?
  callback_after_change_for :update, :delete, :[]=, :remove

  typed_as :string

  def initialize(config, key, typed: nil, default: nil)
    super
  end

  def [](key)
    string_to_type(hget(key))
  end

  def []=(key, value)
    update key => value
  end

  def update(**entries)
    hset entries.transform_values{ |val| type_to_string(val) } if entries.flatten.any?
  end

  def values_at(*keys)
    strings_to_types(hmget(keys) || [])
  end

  def delete(*keys)
    hdel keys if keys.flatten.any?
  end

  def remove
    del
  end
  alias clear remove

  def entries
    (hgetall || {}).transform_values { |val| string_to_type(val) }.with_indifferent_access
  end
  alias to_h entries

  def keys
    hkeys || []
  end

  def values
    strings_to_types(hvals || [])
  end
end
