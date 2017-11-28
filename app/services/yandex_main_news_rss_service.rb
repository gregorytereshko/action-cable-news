class YandexMainNewsRssService < MainNewsRssService

  DEFAULT_URL = 'https://news.yandex.ru/index.rss'.freeze
  IDENTIFIER = 'main_yandex_news'.freeze

  def title
    @main_news.title
  end

  def description
    @main_news.description
  end

  def link
    @main_news.link
  end

  def published_at
    @main_news.pubDate
  end

  private

  def self.default_url
    DEFAULT_URL
  end

  def self.identifier
    IDENTIFIER
  end

end
