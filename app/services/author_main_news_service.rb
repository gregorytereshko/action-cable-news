class AuthorMainNewsService < MainNewsService

  IDENTIFIER = 'main_author_news'.freeze
  attr_accessor :title, :description, :published_at, :expired_at

  def initialize attrs = {}
    # attrs.each do |key, value|
    #   self.send("#{key}=".to_sym, value) if self.respond_to?("#{key}=".to_sym)
    # end
    assing_attributes(attrs)
    super(attrs)
  end

  def properties
    {
      title: title,
      description: description,
      published_at: published_at,
      expired_at: expired_at
    }
  end

  def run_broadcast
    MainNewsBroadcastWorker.perform_async(use.to_h)
  end

  def valid?
    use.to_h.presence && DateTime.current < expired_at.to_datetime
  end

  def validate
    valid? && main_news
  end


  def hashed
    record = validate
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
