# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :admin do
    resources :reports
    resources :orders
    resources :products do
      resources :stocks
      resources :images, only: [:destroy]
    end
    resources :categories
  end

  # namespace :quantities do
  #   resources :mould_rectangle, only: [:index]
  #   resources :area, only: [:index]
  #   resources :dimensions, only: [:index]
  # end

  devise_for :admin_users
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

  # TODO: Restrict access to LetterOpenerWeb in Production once Test env is configured.
  # mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: '/letter_opener'
end
