class MainNewsPolicy

  attr_reader :rss_news

  def initialize(options = {})
    @rss_news = options[:rss_news] || default_rss_news
  end

  def main_news
    rss_news.author_main_news_service.validate || rss_news.use
  end

  private

  def default_rss_news
    YandexMainNewsRssService.new
  end

end
