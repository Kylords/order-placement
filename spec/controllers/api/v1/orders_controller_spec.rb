require 'rails_helper'

RSpec.describe Api::V1::OrdersController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:product1) { create(:product, price: 100) }
  let(:product2) { create(:product, price: 200) }
  let(:order) { create(:order, user: user, status: 'pending') }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    context "as regular user" do
      before { allow(controller).to receive(:current_user).and_return(user) }

      it "returns the user's orders" do
        order_with_items = create(:order, user: user)
        get :index
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        orders_array = json['orders']

        expect(orders_array).to be_an(Array)
        expect(orders_array.first['id']).to eq(order_with_items.id)
      end
    end

    context "as admin" do
      before { allow(controller).to receive(:current_user).and_return(admin) }

      it "returns all orders" do
        order_with_items = create(:order, user: user)
        get :index
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        orders_array = json['orders']

        expect(orders_array.size).to be >= 1
        expect(orders_array.map { |o| o['id'] }).to include(order_with_items.id)
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        items: [
          { product_id: product1.id, quantity: 2 },
          { product_id: product2.id, quantity: 1 }
        ]
      }
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "with valid params" do
      it "creates a new order with correct total amount" do
        expect {
          post :create, params: valid_params
        }.to change(Order, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['total_amount'].to_f).to eq(100*2 + 200*1)
        expect(json['order_items'].size).to eq(2)
      end
    end

    context "with invalid product_id" do
      it "returns unprocessable entity" do
        post :create, params: { items: [{ product_id: 0, quantity: 1 }] }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT #update" do
    before do
      allow(controller).to receive(:current_user).and_return(admin)
      @order = create(:order, user: user, status: 'pending')
    end

    context "with valid status" do
      it "updates the order status" do
        put :update, params: { id: @order.id, status: 'completed' }
        expect(response).to have_http_status(:ok)
        expect(@order.reload.status).to eq('completed')
      end
    end

    context "with invalid status" do
      it "returns unprocessable entity" do
        put :update, params: { id: @order.id, status: nil }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when order does not exist" do
      before { allow(controller).to receive(:current_user).and_return(admin) }

      it "returns 404 not found" do
        put :update, params: { id: 99999, status: 'completed' }
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq("Couldn't find Order with 'id'=99999")
      end
    end
  end
end