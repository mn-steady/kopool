Kopool::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users

  root 'pages#index'

  resources :nfl_teams, only: [:index]
  resources :weeks, only: [:index]

  resources :seasons, only: [:new, :create, :show]
end
