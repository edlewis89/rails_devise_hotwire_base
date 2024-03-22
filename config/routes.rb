require 'sidekiq/web'

Rails.application.routes.draw do
  get 'reviews/new'
  get 'reviews/create'
  get 'reviews/edit'
  get 'reviews/update'
  get 'reviews/destroy'
  get 'dashboard/index'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  resources :users do
    member do
      get :confirm_email
    end
  end

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
      get 'autocomplete', as: :contractors_autocomplete
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

  resources :admins do
    member do
      post :edit
    end
  end

  resources :ad_managers do
    member do
      post :edit
    end
  end

  resources :service_requests do
    post 'bids', to: 'bids#create', as: 'bids'
    resources :service_responses, only: [:index, :new, :create]
    resources :bids do
      member do
        post 'accept'
        post 'reject'
        post 'confirm_acceptance'
      end
    end
  end

  get '/bid_confirmation', to: 'bids#confirmation', as: 'bid_confirmation'

  resources :services, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :advertisements, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :reviews, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  get 'dashboard', to: 'dashboard#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  #get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  post '/send_data', to: 'home#send_data'
  #get '/profile/edit', to: 'users/registrations#edit', as: 'edit_user_profile'
  root 'home#index'
end
