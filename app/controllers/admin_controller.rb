class AdminController < ApplicationController
  skip_before_action :authenticate_request
  
  # Simple admin endpoint to run migrations
  # Secured with ADMIN_SECRET_TOKEN environment variable
  def migrate
    # Check for admin secret token
    provided_token = request.headers['X-Admin-Token'] || params[:token]
    expected_token = ENV['ADMIN_SECRET_TOKEN'] || 'migration-secret-token-change-me'
    
    unless provided_token == expected_token
      render json: { error: "Unauthorized. Provide X-Admin-Token header or token param." }, status: :unauthorized
      return
    end
    
    begin
      # Run migrations using Rails' migration system
      ActiveRecord::MigrationContext.new('db/migrate').migrate
      
      render json: {
        status: "success",
        message: "Migrations completed successfully"
      }, status: :ok
    rescue => e
      Rails.logger.error "Migration error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        status: "error",
        error: e.message,
        class: e.class.name
      }, status: :internal_server_error
    end
  end
end
