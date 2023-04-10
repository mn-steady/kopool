Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users, :controllers => {:sessions => "sessions", registrations: "registrations", passwords: "forgot_passwords" }

  root 'pages#index'

  resources :nfl_teams
  get "pool_entries_index_all", :controller => "pool_entries", :action => "index_all"
  resources :pool_entries


  resources :seasons, only: [:new, :create, :show] do
    get "season_results", :action => "season_results"
    get "season_summary", :action => "season_summary"
    get "season_knockout_counts", :action => "season_knockout_counts"
  	resources :weeks, only: [:index, :new, :create, :edit, :show, :update, :destroy]
  end

  resources :weeks do
    post "close_week", :action => "close_week!"
    post "reopen_week", :action => "reopen_week!"
    post "advance_week", :action => "next_week!"
    get "week_results", :action => "week_results"
    get "week_picks", :controller => "picks", :action => "week_picks"
    get "sorted_picks", :controller => "picks", :action => "sorted_picks"
    get "unpicked", :action => "unpicked"
    get "locked_picks", :action => "locked_picks"
    get "filtered_matchups", :controller => "matchups", :action => "filtered_matchups"
    get "pool_entries_and_picks", :controller => "pool_entries", :action => "pool_entries_and_picks"
    post "create_or_update_pick", :controller => "picks", :action => "create_or_update_pick"
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

  resources :tokens, :only => [:create, :destroy]
end
