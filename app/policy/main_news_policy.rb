class MainNewsPolicy

  attr_reader :main_news

  def initialize(options = {})
    klass = options[:klass] || YandexMainNewsRssService
    @main_news = autor_news.validate || klass.use
  end

  private

  # def autor_news_object
  #   autor_news.valid? ? autor_news.use : nil
  # end

  def autor_news
    AuthorMainNewsService
  end

  def self.redis
    $redis
  end

end
