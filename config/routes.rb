require "sidekiq/web"

Rails.application.routes.draw do
  # Enable Swagger/API docs in development, test, or when ENABLE_API_DOCS is set
  if Rails.env.development? || Rails.env.test? || ENV["ENABLE_API_DOCS"] == "true"
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end
  get "/health", to: "health#show"
  post "/signup", to: "users#create"
  post "/login", to: "sessions#create"
  post "/admin/migrate", to: "admin#migrate"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "health#show"

  mount Sidekiq::Web => "/sidekiq"

  resources :tasks

end
