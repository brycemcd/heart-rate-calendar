Rails.application.routes.draw do
  get 'home/index'
  root to: 'home#index'

  get "/auth/:provider/callback" => "sessions#create"
end
