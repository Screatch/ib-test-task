# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root "calculations#index"
  resources :calculations

  # Sidekiq
  require "sidekiq/web"
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => "/sidekiq"
end
