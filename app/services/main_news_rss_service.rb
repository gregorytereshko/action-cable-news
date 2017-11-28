require 'rss'

class MainNewsRssService < MainNewsService

  def initialize(options = {})
    url = options[:url] || self.class.default_url
    @main_news = RSS::Parser.parse(open(url)).items.first
  end

  def properties
    {
      title: title,
      description: description,
      published_at: published_at,
      link: link
    }
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

end
