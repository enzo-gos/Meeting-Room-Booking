Rails.application.routes.draw do
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

  devise_scope :user do
    authenticated :user do
      get 'user/profile' => 'user#profile'
      root 'dashboard#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
