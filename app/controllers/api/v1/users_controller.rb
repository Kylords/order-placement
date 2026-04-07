module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authorize_request, only: [:create]

      # POST /users
      def create
        user = User.new(user_params)
        if user.save
          # auto-login by issuing JWT
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token, user: { id: user.id, name: user.name, email: user.email, role: user.role } }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /users/:id
      def show
        user = User.find(params[:id])
      
        cart = user.cart
        cart_count = cart&.cart_items&.sum(:quantity) || 0
      
        render json: {
          id: user.id,
          name: user.name,
          email: user.email,
          cart_count: cart_count,
          role: user.role
        }
      end

      private

      def user_params
        params.permit(:name, :email, :password, :password_confirmation, :role)
      end
    end
  end
end