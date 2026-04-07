module Api
  module V1
    class OrdersController < ApplicationController
      # GET /api/v1/orders
      def index
        per_page = (params[:per_page] || 20).to_i
        page = (params[:page] || 1).to_i
        offset = (page - 1) * per_page

        if current_user.role == 'admin'
          @orders = Order.includes(order_items: :product)
                         .order(created_at: :desc)
                         .limit(per_page)
                         .offset(offset)
        else
          @orders = current_user.orders.includes(order_items: :product)
                               .order(created_at: :desc)
                               .limit(per_page)
                               .offset(offset)
        end
        total_count = current_user.role == 'admin' ? Order.count : current_user.orders.count

        render json: {
          data: @orders.map do |order|
            order.as_json.except('order_items').merge(
              items: order.order_items.map do |item|
                item.as_json.merge(
                  product: item.product.as_json,
                  subtotal: item.price * item.quantity
                )
              end
            )
          end,
          meta: {
            page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: (total_count / per_page.to_f).ceil
          }
        }
      end

      # POST /api/v1/orders
      def create
        items_data = params[:items] || []
      
        Order.transaction do
          total_amount = 0
      
          order_items_attributes = items_data.map do |item|
            product = Product.find(item[:product_id])
      
            quantity = item[:quantity].to_i
            price = product.price
            total_amount += price * quantity
      
            {
              product_id: product.id,
              quantity: quantity,
              price: price
            }
          end
      
          @order = Order.new(
            user: current_user,
            status: "pending",
            total_amount: total_amount,
            order_items_attributes: order_items_attributes
          )
      
          @order.save!
      
          render json: {
            message: "Order created successfully",
            data: {
              id: @order.id,
              status: @order.status,
              total_amount: @order.total_amount.to_f,
              items: @order.order_items.map do |item|
                {
                  product_id: item.product_id,
                  quantity: item.quantity,
                  price: item.price.to_f,
                  subtotal: (item.price * item.quantity).to_f
                }
              end
            }
          }, status: :created
        end
      
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      # PUT /api/v1/orders/:id
      def update
        @order = Order.find(params[:id])

        if @order.update(order_status_params)
          render json: @order.as_json(include: { order_items: { include: :product } })
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def order_status_params
        params.permit(:status)
      end
    end
  end
end