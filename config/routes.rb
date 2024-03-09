require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :users do
    member do
      get :confirm_email
    end
  end

  post '/send_data', to: 'home#send_data'

  resources :conversations, only: [:index, :create] do
    resources :messages, only: [:index, :create]
  end

  resources :messages, only: [:new, :create] do
    member do
      post 'reply'
    end
  end

  resources :homeowners do
    #resources :homeowner_requests
    member do
      post :edit
    end
    resources :messages, only: [:index, :new, :create] do
      post :create_message, on: :collection
      member do
        post 'reply'
      end
    end
  end

  resources :contractors do
    collection do
      get 'index', as: :search
    end
    member do
      post :edit
    end
    resources :contractor_homeowner_requests, only: [:index] do
      member do
        patch 'accept'
        patch 'decline'
      end
    end
    resources :messages, only: [:index, :new, :create] do
      post :create_message, on: :collection
      member do
        post 'reply'
      end
    end
  end

  resources :service_requests, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    get 'respond', on: :member
    resources :service_responses, only: [:index, :new, :create]
  end

  resources :services, only: [:index, :new, :create, :edit, :update, :destroy]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  #get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'home#index'
end
