module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_request
      before_action :set_user, only: [:show]

      def show
        render json: {
          id: @user.id,
          name: @user.name,
          email: @user.email,
          created_at: @user.created_at
        }, status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
        # Users can only view their own profile
        unless @user == current_user
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end
    end
  end
end
