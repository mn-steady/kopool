Kopool::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users, :controllers => {:sessions => "sessions"}

  root 'pages#index'

  resources :nfl_teams

  resources :seasons, only: [:new, :create, :show] do
  	resources :weeks, only: [:index, :new]
  end

  resources :weeks do
    resources :matchups
  end
end
