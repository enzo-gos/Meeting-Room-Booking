require 'sidekiq/web'

Rails.application.routes.draw do
  # Mount Sidekiq Web UI
  mount Sidekiq::Web => :sidekiq

  # Admin namespace
  namespace :admin do
    resources :rooms
    resources :users
  end

  # Devise routes for users
  devise_for :users, path: :user, path_names: {
    sign_in: :login,
    sign_out: :logout,
    sign_up: :register
  }, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }

  # Health check endpoint
  get :up, to: 'rails/health#show', as: :rails_health_check

  # Dashboard route
  get :dashboard, to: 'dashboard#index'

  # User profile routes
  resource :users, only: [] do
    collection do
      get :profile, to: 'users#index'
      patch :profile, to: 'users#update'
    end
  end

  # Meeting rooms routes
  resources :meeting_rooms, only: [:index] do
    member do
      get '', to: 'meeting_rooms#schedule', as: :details
      get :book
      post :book, to: 'meeting_rooms#create'
      get :events
    end
  end

  # Reservations routes
  resources :reservations

  # Devise scope for user root paths
  devise_scope :user do
    authenticated :user do
      root 'dashboard#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
