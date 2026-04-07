module Api
  module V1
    class ProductsController < ApplicationController
      # GET /api/v1/products
      def index
        per_page = (params[:per_page] || 20).to_i
        page = (params[:page] || 1).to_i
        offset = (page - 1) * per_page

        status = params[:status]&.downcase || "all"
        @products = case status
                    when "active"
                      Product.where(status: "A")
                    when "created"
                      Product.where(status: "C")
                    else
                      Product.all
                    end

        total_count = @products.count
        total_pages = (total_count / per_page.to_f).ceil

        @products = @products.offset(offset).limit(per_page)

        render json: {
          products: @products.as_json(only: [:id, :name, :code, :price, :status]),
          meta: {
            page: page,
            per_page: per_page,
            total_count: total_count,
            total_pages: total_pages
          }
        }
      end

      # GET /api/v1/products/:id
      def show
        @product = Product.find(params[:id])
        render json: @product
      end

      # -----------------------------
      # SINGLE PRODUCT ENDPOINTS
      # -----------------------------

      # POST /api/v1/products/single
      def create_single
        @product = Product.new(single_product_params)

        if @product.save
          render json: @product, status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/products/:id
      def update
        @product = Product.find(params[:id])

        if @product.update(single_product_params)
          render json: @product
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # -----------------------------
      # BATCH PRODUCT ENDPOINTS
      # -----------------------------

      # POST /api/v1/products/batch
      def create_batch
        status = params[:status]
        unless ["A", "C"].include?(status)
          return render json: { errors: ["Invalid status"] }, status: :unprocessable_entity
        end
        products_data = params[:data] || []

        created_products = []
        Product.transaction do
          products_data.each do |p|
            created_products << Product.create!(name: p[:name], code: p[:code], price: p[:price], status: status)
          end
        end

        render json: { status: status, data: created_products }, status: :created

      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      # PUT /api/v1/products/batch_tatus
      def update_batch_status
        new_status = params[:status]
        unless ["A", "C"].include?(new_status)
          return render json: { errors: ["Invalid status"] }, status: :unprocessable_entity
        end
        products_data = params[:data] || []
        codes = products_data.map { |p| p[:code] }

        updated_products = []
        Product.transaction do
          products = Product.where(code: codes)
          products.update_all(status: new_status)
          updated_products = products
        end

        render json: { status: new_status, updated_count: updated_products.size, data: updated_products }
      end

      def destroy
        @product = Product.find(params[:id])
        @product.destroy
        head :no_content
      end

      private

      # Single product creation/updating
      def single_product_params
        params.require(:product).permit(:name, :code, :price, :status)
      end
    end
  end
end