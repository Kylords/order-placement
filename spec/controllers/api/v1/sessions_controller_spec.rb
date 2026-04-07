require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  describe 'POST #create' do
    let(:password) { 'password123' }
    let(:user) { create(:user, password: password, password_confirmation: password) }
    let(:cart) { create(:cart, user: user) }

    before do
      create(:cart_item, cart: cart, quantity: 2)
    end

    context 'with valid credentials' do
      it 'returns token and user info including cart_count' do
        post :create, params: { email: user.email, password: password }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
        expect(json['user']['id']).to eq(user.id)
        expect(json['user']['email']).to eq(user.email)
        expect(json['user']['role']).to eq(user.role)
        expect(json['user']['cart_count']).to eq(2)
      end
    end

    context 'with invalid password' do
      it 'returns unauthorized error' do
        post :create, params: { email: user.email, password: 'wrongpassword' }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid email or password')
      end
    end

    context 'with non-existent email' do
      it 'returns unauthorized error' do
        post :create, params: { email: 'nonexistent@example.com', password: 'any' }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid email or password')
      end
    end

    context 'with user who has no cart' do
      it 'returns cart_count as 0' do
        user_without_cart = create(:user, password: password, password_confirmation: password)
        post :create, params: { email: user_without_cart.email, password: password }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['cart_count']).to eq(0)
      end
    end
  end
end