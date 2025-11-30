# frozen_string_literal: true

Rails.application.routes.draw do
  # Customer user authentication routes
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }

  # User dashboard routes (requires authentication)
  authenticated :user do
    resource :account, only: %i[show edit update], controller: 'users/accounts'
    resources :addresses, controller: 'users/addresses' do
      member do
        patch :set_primary
      end
    end
    resources :orders, only: %i[index show], controller: 'users/orders'
  end

  namespace :admin do
    resources :reports
    resources :orders
    resources :products do
      resources :stocks
      resources :images, only: [:destroy]
    end
    resources :categories
    resources :audit_logs, only: [:index] do
      collection do
        get :export
      end
    end
  end

  # API endpoints for cart persistence
  namespace :api do
    resource :cart, only: [:show] do
      post :sync
      post :merge
      delete :clear
    end
  end

  # namespace :quantities do
  #   resources :mould_rectangle, only: [:index]
  #   resources :area, only: [:index]
  #   resources :dimensions, only: [:index]
  # end

  devise_for :admin_users, controllers: {
    sessions: 'admin_users/sessions'
  }

  # Two-factor authentication routes for admin users
  namespace :admin_users do
    resource :two_factor, only: %i[new create edit destroy], controller: 'two_factor' do
      post :regenerate_backup_codes
    end
    resource :two_factor_verification, only: %i[new create], controller: 'two_factor_verification'
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'home#index'

  # root "contact_form#new"
  # resources :contact_form, only: %i[new create]
  get 'contact' => 'contact#index'
  post 'contact' => 'contact#create'

  authenticated :admin_user do
    root to: 'admin#index', as: :admin_root
  end

  resources :categories, only: [:show]
  resources :products, only: [:show]

  get 'search' => 'search#index'

  get 'admin' => 'admin#index'
  get 'cart' => 'carts#show'
  post 'checkout' => 'checkouts#create'
  get 'success' => 'checkouts#success'
  get 'cancel' => 'checkouts#cancel'
  get 'quantities' => 'quantities#index'
  get 'quantities/area' => 'quantities/area#index'
  get 'quantities/dimensions' => 'quantities/dimensions#index'
  get 'quantities/mould_rectangle' => 'quantities/mould_rectangle#index'

  post 'webhooks' => 'webhooks#stripe'

  # CSP violation reporting endpoint
  post 'csp_violations' => 'csp_violations#create'

  # Custom error pages with error tracking IDs
  match '/404', to: 'errors#not_found', via: :all, as: 'errors_not_found'
  match '/422', to: 'errors#unprocessable_entity', via: :all, as: 'errors_unprocessable_entity'
  match '/500', to: 'errors#internal_server_error', via: :all, as: 'errors_internal_server_error'

  # LetterOpenerWeb is restricted to development environment only for security
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
