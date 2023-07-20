Rails.application.routes.draw do
  namespace :admin do
      resources :users
      resources :bubble_uploads
      resources :seasons
      resources :main_page_bubbles

      root to: "users#index"
  end
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
    get "pool_image", action: 'pool_image'
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
    post "/unpicked/default_pool_entry", to: 'pool_entries#default_pool_entry'
    resources :matchups do
      collection do
        post "save_outcome", :action => "save_outcome"
        post "revert_outcome", :action => "revert_outcome"
      end
    end
    resources :picks
  end

  namespace :commissioner do
    resources :web_states
  end

  get "/main_image", to: 'seasons#main_page_image'
  resources :tokens, :only => [:create, :destroy]
end
