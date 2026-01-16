class SessionsController < ApplicationController
    skip_before_action :authenticate_request, only: [:create]
    def create
      user = User.find_by(email: params[:email])
  
      if user&.authenticate(params[:password])
        token = JsonWebToken.encode(user_id: user.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: "Invalid credentials" }, status: :unauthorized
      end
    end
  end
  