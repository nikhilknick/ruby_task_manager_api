class ApplicationController < ActionController::API
  before_action :authenticate_request, unless: :public_endpoint?

  attr_reader :current_user

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last

    decoded = JsonWebToken.decode(token)
    @current_user = User.find_by(id: decoded[:user_id]) if decoded

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  def public_endpoint?
    controller_name.in?(%w[health users sessions])
  end
end
