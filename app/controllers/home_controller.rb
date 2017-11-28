class HomeController < ApplicationController
  def index
    @main_news = MainNewsPolicy.new.main_news
  end

  def admin
    @form = AuthorNewsForm.new(AuthorMainNewsService.hashed)
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
end
