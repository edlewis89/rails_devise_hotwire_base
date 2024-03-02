Rails.application.routes.draw do

  devise_for :users

  post '/send_data', to: 'home#send_data'

  resources :homeowners do
    #resources :homeowner_requests
    member do
      post :edit
    end
    #resource :profile, only: [:edit, :update]
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
    #resource :profile, only: [:edit, :update]
  end

  resources :service_requests, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    get 'respond', on: :member
  end
  # resources :contractor_profiles, only: [:edit, :update]
  # resources :homeowner_profiles, only: [:edit, :update]

  resources :type_of_works, only: [:index, :new, :create, :edit, :update, :destroy]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  #get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  root 'home#index'
end
