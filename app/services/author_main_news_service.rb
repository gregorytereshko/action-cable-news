class AuthorMainNewsService < MainNewsService

  IDENTIFIER = 'main_author_news'.freeze
  attr_accessor :title, :description, :published_at, :expired_at

  def initialize attrs = {}
    # attrs.each do |key, value|
    #   self.send("#{key}=".to_sym, value) if self.respond_to?("#{key}=".to_sym)
    # end
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def properties
    {
      title: title,
      description: description,
      published_at: published_at,
      expired_at: expired_at
    }
  end

  def self.validate
    record = self.use
    record.presence && DateTime.current < record.expired_at.to_datetime && record
  end

  def self.hashed
    record = self.validate
    if record
      record.to_h
    else
      {}
    end
  end

  private

  def self.identifier
    IDENTIFIER
  end

end
