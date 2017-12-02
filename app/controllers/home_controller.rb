class HomeController < ApplicationController
  def index
    author_redis_service = RedisHashService.new(AuthorMainNewsService.identifier, redis: redis)
    rss_redis_service = RedisHashService.new(YandexMainNewsRssService.identifier, redis: redis)
    author_main_news = AuthorMainNewsService.new(redis_service: author_redis_service)
    rss_main_news = YandexMainNewsRssService.new(
                                                  redis_service: rss_redis_service,
                                                  author_main_news_service: author_main_news
                                                )
    @main_news = MainNewsPolicy.new(rss_news: rss_main_news).main_news
  end

  def admin
    @form = AuthorNewsForm.new(AuthorMainNewsService.new.hashed)
  end

  def news_create
    @author_news_form = AuthorNewsForm.new(author_news_form_params)
    if @author_news_form.save
      redirect_to root_path
    else
      redirect_to admin_path
    end
  end

  private

  def author_news_form_params
    params.require(:author_news_form).permit(:title, :description, :expired_at)
  end

  def redis
    $redis
  end
end
