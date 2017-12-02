class YandexMainNewsRssService < MainNewsRssService

  DEFAULT_URL = 'https://news.yandex.ru/index.rss'.freeze
  IDENTIFIER = 'main_yandex_news'.freeze

  private

  def set_properties
    @title = @main_news&.title
    @description = @main_news&.description
    @link = @main_news&.link
    @published_at = @main_news&.pubDate
  end

  def self.default_url
    DEFAULT_URL
  end

  def self.identifier
    IDENTIFIER
  end

end
