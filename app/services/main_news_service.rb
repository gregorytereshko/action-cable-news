class MainNewsService

  PROPERTIES = %w(title description published_at).freeze

  attr_accessor :main_news, :redis_service

  def initialize(options = {})
    @redis_service = options[:redis_service] || default_redis_service
  end

  (PROPERTIES).each do |method_name|
    define_method(method_name) do
      raise NotImplementedError, "Subclasses must define '#{method_name}'."
    end
  end

  def properties
    raise NotImplementedError, "Subclasses must define 'properties'."
  end

  def save!
    if present? && !redis_service.same?(properties)
      persist!
      run_broadcast
      true
    else
      false
    end
  end

  def run_broadcast
    raise NotImplementedError, "Subclasses must define 'run_broadcast'."
  end

  def assing_attributes attrs = {}
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def use
    @main_news = redis_service.structured
    assing_attributes(@main_news.to_h)
    @main_news
  end

  private

  def present?
    properties.values.all? { |val| val.present? }
  end

  def persist!
    redis_service.set(properties)
  end

  def default_redis_service
    RedisHashService.new(self.class.identifier)
  end

  def self.identifier
    raise NotImplementedError, "Subclasses must define 'identifier'."
  end

end
