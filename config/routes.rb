require 'sidekiq/web'

Rails.application.routes.draw do

  mount Sidekiq::Web, at: '/sidekiq'
  mount ActionCable.server => '/cable'

  root to: 'home#index'

  get 'admin', to: 'home#admin'
  post 'home/admin', to: 'home#news_create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
