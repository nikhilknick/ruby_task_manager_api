require "sidekiq/web"

Rails.application.routes.draw do
  # Enable Swagger/API docs in development, test, or when ENABLE_API_DOCS is set
  if Rails.env.development? || Rails.env.test? || ENV["ENABLE_API_DOCS"] == "true"
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  end
  
  # Health check endpoints (public)
  get "/health", to: "health#show"
  get "up" => "rails/health#show", as: :rails_health_check
  root "health#show"

  # Public authentication endpoints
  post "/signup", to: "users#create"
  post "/login", to: "sessions#create"
  
  # Admin endpoints
  namespace :admin do
    post "/migrate", to: "admin#migrate"
  end

  mount Sidekiq::Web => "/sidekiq"

  # API routes with versioning
  namespace :api do
    namespace :v1 do
      # Nested routes: users -> tasks
      resources :users, constraints: { id: /\d+/ }, only: [:show] do
        resources :tasks, constraints: { id: /\d+/ }, except: [:new, :edit] do
          # Custom collection route for statistics
          collection do
            get :statistics
          end
        end
      end

      # Standalone tasks routes (for backward compatibility and direct access)
      resources :tasks, constraints: { id: /\d+/ }, except: [:new, :edit] do
        # Custom collection route for statistics
        collection do
          get :statistics
        end
      end
    end
  end

  # Legacy routes (for backward compatibility - can be removed in future)
  resources :tasks, constraints: { id: /\d+/ }, except: [:new, :edit] do
    collection do
      get :statistics
    end
  end
end
