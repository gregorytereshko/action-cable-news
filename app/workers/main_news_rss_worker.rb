class MainNewsRssWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default", retry: 3

  def perform(options = {})
    klass = options[:klass] || 'YandexMainNewsRssService'.constantize
    klass.new(url: options[:url]).save!

    MainNewsBroadcastWorker.perform_async(main_news_hash)
  end

  private

  def main_news_hash
    MainNewsPolicy.new.main_news.to_h
  end
end
