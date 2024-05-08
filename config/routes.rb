require 'sidekiq/web'

#TODO: Refactor for clean routing
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  namespace :admin do
    resources :meeting_room_management, path: 'rooms'
  end

  devise_for :users, path: '/user', path_names: {
    :sign_in => 'login',
    :sign_out => 'logout',
    :sign_up => 'register'
  },
  controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: 'users/registrations'
  }

  get 'up' => 'rails/health#show', as: :rails_health_check

  get 'dashboard' => 'dashboard#index'

  # TODO: Refactor this
  get 'user/profile' => 'user#index'
  patch 'user/profile' => 'user#update'

  resources :meeting_rooms, only: [:index] do
    member do
      get '/', to: 'meeting_rooms#schedule', as: 'details'
      get 'book'
      post 'book', to: 'meeting_rooms#create'
      get 'events'
    end
  end

  resources :reservation

  # TODO: Refactor this
  get '/google/calendar' => 'calendars#redirect'
  get '/google/calendar/callback' => 'calendars#callback'

  devise_scope :user do
    authenticated :user do
      root 'dashboard#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
