module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :authorize_request, only: [:create]

      def create
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          cart = user.cart
          cart_count = cart&.cart_items&.sum(:quantity) || 0
          render json: { token: token, user: { id: user.id, name: user.name, email: user.email, role: user.role, cart_count: cart_count } }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end
    end
  end
end
