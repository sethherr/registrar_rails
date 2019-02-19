# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }

  root "landing#index"

  resource :account, only: %i[show edit update]

  resources :registrations, :attestations

  resources :documentation, only: [:index] do
    collection do
      get :api_v1
    end
  end

  namespace :admin do
    root to: "users#index"
    get :clear_cache, to: "dashboard#clear_cache"
    resources :users, :registrations
  end

  authenticate :user, lambda { |u| u.developer? } do
    mount Sidekiq::Web, at: "/sidekiq"
  end

  get "/400", to: "errors#bad_request", via: :all
  get "/401", to: "errors#unauthorized", via: :all
  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#server_error", via: :all

  # Grape API - must be below routes so it doesn't override
  mount API::Base => "/api"
end
