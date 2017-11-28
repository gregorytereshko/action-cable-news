class MainNewsService

  PROPERTIES = %w(title description published_at link).freeze
  METHODS = %w(save!).freeze

  attr_accessor :main_news

  (PROPERTIES + METHODS).each do |method_name|
    define_method(method_name) do
      raise NotImplementedError, "Subclasses must define '#{method_name}'."
    end
  end

  def properties
    raise NotImplementedError, "Subclasses must define 'properties'."
  end

  def save!
    self.class.redis.set(self.class.identifier, properties.to_json)
  end

  def self.use
    result = redis.get(identifier)
    return nil if result.blank?
    JSON.parse(result, object_class: OpenStruct)
  end

  private

  def self.identifier
    raise NotImplementedError, "Subclasses must define 'identifier'."
  end

  def self.redis
    $redis
  end

end
