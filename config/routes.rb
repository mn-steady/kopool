Kopool::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users, :controllers => {:sessions => "sessions"}

  root 'pages#index'

  resources :nfl_teams
  resources :pool_entries

  resources :seasons, only: [:new, :create, :show] do
  	resources :weeks, only: [:index, :new, :create, :edit, :show, :update, :destroy]
  end

  resources :weeks do
    resources :matchups do
      collection do
        post "save_outcome", :action => "save_outcome"
      end
    end
    resources :picks
  end

  namespace :admin do
    resources :web_states
  end
end
