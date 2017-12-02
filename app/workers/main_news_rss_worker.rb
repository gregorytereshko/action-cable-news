class MainNewsRssWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default", retry: 3

  def perform(options = {})
    klass = options[:klass] || 'YandexMainNewsRssService'.constantize
    main_news = klass.new(url: options[:url])
    main_news.load_main_news
    main_news.save!
  end

end
