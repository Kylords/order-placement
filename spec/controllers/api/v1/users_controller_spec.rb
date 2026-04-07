require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'POST #create' do
    let(:valid_params) do
      {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password',
        password_confirmation: 'password',
        role: 'customer'
      }
    end

    let(:invalid_params) do
      {
        name: '',
        email: 'invalid-email',
        password: '123',
        password_confirmation: '456',
        role: 'customer'
      }
    end

    context 'with valid params' do
      it 'creates a new user and returns token' do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['token']).to be_present
        expect(json['user']['email']).to eq('john@example.com')
        expect(json['user']['role']).to eq('customer')
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity with errors' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Name can't be blank")
        expect(json['errors']).to include("Password confirmation doesn't match Password")
      end
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user) }
    let(:cart) { create(:cart, user: user) }

    before do
      create(:cart_item, cart: cart, quantity: 3)
    end

    it 'returns user details with cart_count' do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(user.id)
      expect(json['email']).to eq(user.email)
      expect(json['role']).to eq(user.role)
      expect(json['cart_count']).to eq(3)
    end

    it 'returns cart_count 0 if user has no cart' do
      user_without_cart = create(:user)
      get :show, params: { id: user_without_cart.id }
      json = JSON.parse(response.body)
      expect(json['cart_count']).to eq(0)
    end

    it 'returns 404 if user does not exist' do
      get :show, params: { id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end
end