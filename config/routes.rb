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
        post 'selected', :action => "save_week_outcomes"
      end
    end
    resources :picks
  end
end
