class ApplicationController < ActionController::API
  rescue_from StandardError do |e|
    render json: { error: e.message }, status: :forbidden
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: exception.message }, status: :not_found
  end
  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    decoded = JsonWebToken.decode(header)
    @current_user = User.find(decoded[:user_id]) if decoded
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: 'Unauthorized' }, status: :unauthorized
  end
end