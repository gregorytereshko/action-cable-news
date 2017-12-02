require 'rss'

class MainNewsRssService < MainNewsService

  METHODS = %w(set_properties)

  attr_accessor :url, :author_main_news_service
  attr_reader :title, :description, :published_at, :link

  def initialize(options = {})
    @url = options[:url] || self.class.default_url
    @author_main_news_service = options[:author_main_news_service] || AuthorMainNewsService.new
    super(options)
  end

  (METHODS).each do |method_name|
    define_method(method_name) do
      raise NotImplementedError, "Subclasses must define '#{method_name}'."
    end
  end

  def properties
    {
      title: title,
      description: description,
      published_at: published_at,
      link: link
    }
  end

  def load_main_news
    @main_news = parse(open(@url)).first

    set_properties
  end

  def parse rss
    if respond?(rss)
      RSS::Parser.parse(rss).items
    else
      []
    end
  end

  def run_broadcast
    unless author_main_news_service.valid?
      MainNewsBroadcastWorker.perform_async(use.to_h)
    end
  end

  def self.run(interval = 1, url = nil)
    Sidekiq::Cron::Job.create(
      name: self.identifier,
      cron: "*/#{interval} * * * *",
      class: 'MainNewsRssWorker',
      queue: 'default',
      args: { klass: self, url: url }
    )
  end

  def self.stop
    Sidekiq::Cron::Job.destroy self.identifier
  end

  private

  def self.default_url
    raise NotImplementedError, "Subclasses must define 'default_url'."
  end

  def respond? opened
    opened.status == ['200', 'OK']
  end

  def set_properties
    raise NotImplementedError, "Subclasses must define 'set_properties'."
  end

end
