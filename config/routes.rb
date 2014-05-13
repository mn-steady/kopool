Kopool::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users, :controllers => {:sessions => "sessions"}

  root 'pages#index'

  resources :nfl_teams, only: [:index]

  resources :seasons, only: [:new, :create, :show] do
  	resources :weeks, only: [:index]
  end
end
