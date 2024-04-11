Rails.application.routes.draw do
  devise_for :users, path: '/user', path_names: {
    :sign_in => 'login',
    :sign_out => 'logout',
    :sign_up => 'register'
  },
  controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }


  get "up" => "rails/health#show", as: :rails_health_check
  get "dashboard" => "dashboard#index"

  root "dashboard#index"
end
