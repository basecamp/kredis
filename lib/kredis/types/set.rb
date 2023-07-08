class Kredis::Types::Set < Kredis::Types::Proxying
  prepend Kredis::DefaultValues

  proxying :smembers, :sadd, :srem, :multi, :del, :sismember, :scard, :spop, :exists?, :srandmember
  callback_after_change_for :add, :<<, :remove, :replace, :take, :clear

  def initialize(config, key, typed: nil, default: nil)
    super
  end

  def members
    strings_to_types(smembers || []).sort
  end
  alias to_a members

  def add(*members)
    sadd types_to_strings(members) if members.flatten.any?
  end
  alias << add

  def remove(*members)
    srem types_to_strings(members) if members.flatten.any?
  end

  def replace(*members)
    multi do
      del
      add members
    end
  end

  def include?(member)
    sismember type_to_string(member)
  end

  def size
    scard.to_i
  end

  def take
    string_to_type(spop)
  end

  def clear
    del
  end

  def sample(count = nil)
    if count.nil?
      string_to_type(srandmember(count))
    else
      strings_to_types(srandmember(count))
    end
  end

  private
    def set_default
      add default
    end
end
