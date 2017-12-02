class MainNewsBroadcastWorker
  include Sidekiq::Worker

  sidekiq_options queue: "default", retry: 3

  def perform(main_news_hash)
    byebug
    object = OpenStruct.new main_news_hash
    ActionCable.server.broadcast 'main_news', main_news: render_main_news(object)
  end

  private

  def render_main_news(main_news)
    ApplicationController.renderer.render(partial: 'home/main_news', locals: { main_news: main_news })
  end

end
