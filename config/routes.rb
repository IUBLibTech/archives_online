# frozen_string_literal: true
require "sidekiq/web" # require the web UI

Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  ##### REMOVE SEARCH HISTORY #####
  # Note: has to be before we mount Blacklight::Engine
  get '/search_history', to: 'application#render404'
  delete '/search_history/clear', to: 'application#render404'

  mount Blacklight::Engine => '/'
  mount Arclight::Engine => '/'
  mount Sidekiq::Web => "/sidekiq"

  root to: 'arclight/repositories#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  # Admin page routes
  get '/admin', to: 'admin#index', as: 'admin'
  get 'admin/index_eads', to: 'admin#index_eads', as: 'index_eads'
  get 'admin/index_repository', to: 'admin#index_repository', as: 'index_repository'
  get 'admin/index_ead', to: 'admin#index_ead', as: 'index_ead'
  get 'admin/delete_ead', to: 'admin#delete_ead', as: 'delete_ead'
  delete 'admin/delete_user/:id', to: 'admin#delete_user', as: 'admin_delete_user'
  get 'admin/update_user_role/:id', to: 'admin#update_user_role', as: 'admin_update_user_role'
  get 'admin/edit_repository/:id', to: 'admin#edit_repository', as: 'admin_edit_repository'
  patch 'admin/update_repository/:id', to: 'admin#update_repository', as: 'admin_update_repository'

  if ENV['AL_AUTHN'] == 'database'
    devise_for :users
  else
    devise_for :users, controllers: { sessions: 'users/sessions', omniauth_callbacks: "users/omniauth_callbacks" },
               skip: [:sessions, :passwords, :registration]
    devise_scope :user do
      get 'users/auth/cas', to: 'users/omniauth_authorize#passthru', defaults: { provider: :cas }, as: "new_user_session"
      get('global_sign_out',
          to: 'users/sessions#global_logout',
          as: :destroy_global_session)
      get "users/auth/cas",
          to: 'users/omniauth_authorize#passthru',
          defaults: { provider: :cas }, as: "new_cas_user_session"
    end
  end


  concern :exportable, Blacklight::Routes::Exportable.new
  concern :hierarchy, Arclight::Routes::Hierarchy.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :hierarchy
    concerns :exportable
  end

  ##### REMOVE BOOKMARK #####
  # resources :bookmarks do
  #   concerns :exportable
  #   collection do
  #     delete 'clear'
  #   end
  # end

  get '/about', to: 'pages#about', as: 'about'
  get '/contribute', to: 'pages#contribute', as: 'contribute'
  get '/help', to: 'pages#help', as: 'help'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

end
