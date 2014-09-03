Kopool::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users, :controllers => {:sessions => "sessions", registrations: "registrations" }

  root 'pages#index'

  resources :nfl_teams
  get "pool_entries_index_all", :controller => "pool_entries", :action => "index_all"
  resources :pool_entries
  get "pool_entries_and_picks", :controller => "pool_entries", :action => "pool_entries_and_picks"


  resources :seasons, only: [:new, :create, :show] do
    get "season_results", :action => "season_results"
  	resources :weeks, only: [:index, :new, :create, :edit, :show, :update, :destroy]
  end

  resources :weeks do
    post "close_week", :action => "close_week!"
    post "reopen_week", :action => "reopen_week!"
    post "advance_week", :action => "next_week!"
    get "week_results", :action => "week_results"
    get "week_picks", :controller => "picks", :action => "week_picks"
    get "unpicked", :action => "unpicked"
    get "filtered_matchups", :controller => "matchups", :action => "filtered_matchups"
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
