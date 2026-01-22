class UsersController < ApplicationController
    skip_before_action :authenticate_request, only: [:create]
    
    def create
      user = User.new(user_params)
  
      if user.save
        token = JsonWebToken.encode(user_id: user.id)
        render json: { token: token }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Signup error: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Internal server error", message: e.message }, status: :internal_server_error
    end
  
    private
  
    def user_params
      # Support both nested (user: {...}) and flat params (...)
      if params[:user].present?
        params.require(:user).permit(:email, :name, :password, :password_confirmation)
      else
        params.permit(:email, :name, :password, :password_confirmation)
      end
    end
  end
  