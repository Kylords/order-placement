module Api
  module V1
    class CartsController < ApplicationController
      before_action :authorize_request
      before_action :ensure_customer
      before_action :set_cart

      # GET /api/v1/cart
      def show
        @cart.cart_items.includes(:product)
        render json: @cart.as_json(include: { cart_items: { include: :product } })
      end

      # POST /api/v1/cart/add
      def add_item
        cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
        
        if cart_item
          cart_item.quantity += params[:quantity].to_i
          cart_item.save!
        else
          @cart.cart_items.create!(product_id: params[:product_id], quantity: params[:quantity])
        end

        @cart.update_total_amount!
        cart_count = @cart.cart_items.sum(:quantity)
        render json: {cart: @cart.as_json(include: { cart_items: { include: :product } }), cart_count: cart_count}
      end

      # PUT /api/v1/cart/update
      def update_item
        cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
        if cart_item
          cart_item.update(quantity: params[:quantity])
          @cart.update_total_amount!
          cart_count = @cart.cart_items.sum(:quantity)
          render json: {cart: @cart.as_json(include: { cart_items: { include: :product } }), cart_count: cart_count}
        else
          render json: { error: "Cart item not found" }, status: :not_found
        end
      end

      # DELETE /api/v1/cart/remove
      def remove_item
        cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
        if cart_item
          cart_item.destroy
          @cart.update_total_amount!
          cart_count = @cart.cart_items.sum(:quantity)
          render json: {cart: @cart.as_json(include: { cart_items: { include: :product } }), cart_count: cart_count}
        else
          render json: { error: "Cart item not found" }, status: :not_found
        end
      end

      # POST /api/v1/cart/checkout
      def checkout
        order = @cart.checkout
        render json: order.as_json(include: { order_items: { include: :product } })
      end

      private

      def set_cart
        @cart = current_user.cart || current_user.create_cart
      end

      def ensure_customer
        if current_user.role == 'admin'
          render json: { error: 'Admins are not allowed to use the cart' }, status: :forbidden
        end
      end
    end
  end
end