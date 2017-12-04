class RedisHashService

  attr_accessor :redis, :key
  attr_reader :value

  def initialize(key, options = {})
    @key = key
    @redis = options[:redis] || default_redis_conn
  end

  def set(value)
    raise TypeError, 'Passed value must be a hash' unless value.kind_of?(Hash)
    @redis.set(@key, value&.to_json)
  end

  def get
    @value = @redis.get(@key)
    @value.presence || {}.to_json
  end

  def del
    @redis.del(@key)
  end

  def structured
    JSON.parse(get, object_class: OpenStruct)
  end

  def hashed
    JSON.parse(get)
  end

  def same?(value)
    hashed == JSON.parse(value.to_json)
  end

  def present?
    hashed.present?
  end

  private

  def default_redis_conn
    $redis
  end


end
