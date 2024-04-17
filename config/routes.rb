Rails.application.routes.draw do
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

  get "up" => "rails/health#show", as: :rails_health_check

  get "dashboard" => "dashboard#index"

  get 'user/profile' => 'user#index'
  patch 'user/profile' => 'user#update'

  devise_scope :user do
    authenticated :user do
      root 'dashboard#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
