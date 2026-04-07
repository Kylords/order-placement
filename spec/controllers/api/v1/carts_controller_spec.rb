require 'rails_helper'

RSpec.describe Api::V1::CartsController, type: :controller do
  let(:customer) { create(:user, role: 'customer') }
  let(:admin) { create(:user, role: 'admin') }
  let(:product) { create(:product, price: 10.0) }
  let(:cart) { create(:cart, user: customer) }

  before do
    allow(controller).to receive(:authorize_request).and_return(true)
    allow(controller).to receive(:current_user).and_return(customer)
  end

  describe 'GET #show' do
    it 'returns the cart with items' do
      cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)
      get :show
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['cart_items'].first['product']['id']).to eq(product.id)
    end
  end

  describe 'POST #add_item' do
    it 'adds a new product to the cart' do
      post :add_item, params: { product_id: product.id, quantity: 3 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['cart_count']).to eq(3)
      expect(json['cart']['cart_items'].first['product']['id']).to eq(product.id)
    end

    it 'increments quantity if product already in cart' do
      create(:cart_item, cart: cart, product: product, quantity: 2)
      post :add_item, params: { product_id: product.id, quantity: 3 }
      expect(JSON.parse(response.body)['cart_count']).to eq(5)
    end
  end

  describe 'PUT #update_item' do
    it 'updates the quantity of a cart item' do
      create(:cart_item, cart: cart, product: product, quantity: 2)
      put :update_item, params: { product_id: product.id, quantity: 5 }
      expect(JSON.parse(response.body)['cart_count']).to eq(5)
    end

    it 'returns not found if product not in cart' do
      put :update_item, params: { product_id: 999, quantity: 5 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Cart item not found')
    end
  end

  describe 'DELETE #remove_item' do
    it 'removes a cart item' do
      create(:cart_item, cart: cart, product: product, quantity: 2)
      delete :remove_item, params: { product_id: product.id }
      expect(JSON.parse(response.body)['cart_count']).to eq(0)
    end

    it 'returns not found if product not in cart' do
      delete :remove_item, params: { product_id: 999 }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Cart item not found')
    end
  end

  describe 'POST #checkout' do
    it 'creates an order from the cart' do
      create(:cart_item, cart: cart, product: product, quantity: 2)
      post :checkout
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['order_items'].first['product']['id']).to eq(product.id)
    end
  end

  describe 'ensure_customer before_action' do
    let(:admin) { create(:user, role: 'admin') }
  
    before do
      allow(controller).to receive(:authorize_request).and_return(true)
      allow(controller).to receive(:current_user).and_return(admin)
    end

    it 'returns forbidden for admin user' do
      allow(controller).to receive(:current_user).and_return(admin)
      get :show
      expect(response).to have_http_status(:forbidden)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Admins are not allowed to use the cart')
    end
  end
end