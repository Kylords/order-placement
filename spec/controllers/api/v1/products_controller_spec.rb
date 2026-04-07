require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  let!(:product1) { create(:product, status: 'A') }
  let!(:product2) { create(:product, status: 'C') }
  let!(:product3) { create(:product, status: 'A') }

  describe 'GET #index' do
    it 'returns all products with default pagination' do
      get :index
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['products'].size).to eq(Product.count)
      expect(json['meta']['page']).to eq(1)
      expect(json['meta']['per_page']).to eq(20)
      expect(json['meta']['total_count']).to eq(Product.count)
    end

    it 'filters active products' do
      get :index, params: { status: 'active' }
      json = JSON.parse(response.body)
      expect(json['products'].all? { |p| p['status'] == 'A' }).to be true
    end

    it 'filters created products' do
      get :index, params: { status: 'created' }
      json = JSON.parse(response.body)
      expect(json['products'].all? { |p| p['status'] == 'C' }).to be true
    end

    it 'handles pagination' do
      get :index, params: { page: 1, per_page: 2 }
      json = JSON.parse(response.body)
      expect(json['products'].size).to eq(2)
      expect(json['meta']['total_pages']).to eq((Product.count / 2.0).ceil)
    end
  end

  describe 'GET #show' do
    it 'returns a product' do
      get :show, params: { id: product1.id }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(product1.id)
    end

    it 'returns 404 if user does not exist' do
      get :show, params: { id: 0 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create_single' do
    let(:valid_params) { { product: { name: 'New Product', code: 'NP01', price: 100, status: 'A' } } }
    let(:invalid_params) { { product: { name: '', code: '', price: nil, status: 'X' } } }

    it 'creates a product with valid params' do
      expect {
        post :create_single, params: valid_params
      }.to change(Product, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('New Product')
    end

    it 'returns errors with invalid params' do
      post :create_single, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_present
    end
  end

  describe 'PUT #update' do
    it 'updates a product' do
      put :update, params: { id: product1.id, product: { name: 'Updated Name' } }
      expect(response).to have_http_status(:ok)
      expect(product1.reload.name).to eq('Updated Name')
    end

    it 'returns errors for invalid update' do
      put :update, params: { id: product1.id, product: { name: '' } }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include("Name can't be blank")
    end
  end

  describe 'DELETE #destroy' do
    it 'deletes a product' do
      delete :destroy, params: { id: product1.id }
      expect(response).to have_http_status(:no_content)
      expect { product1.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #create_batch' do
    let(:valid_batch) do
      {
        status: 'A',
        data: [
          { name: 'Batch 1', code: 'B01', price: 50 },
          { name: 'Batch 2', code: 'B02', price: 60 }
        ]
      }
    end

    it 'creates multiple products' do
      expect {
        post :create_batch, params: valid_batch
      }.to change(Product, :count).by(2)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('A')
      expect(json['data'].size).to eq(2)
    end

    it 'returns errors for invalid status' do
      post :create_batch, params: valid_batch.merge(status: 'X')
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Invalid status')
    end
  end

  describe 'PUT #update_batch_status' do
    let(:batch_codes) { [product1.code, product2.code] }

    it 'updates status for multiple products' do
      put :update_batch_status, params: { status: 'A', data: batch_codes.map { |c| { code: c } } }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('A')
      expect(json['updated_count']).to eq(2)
      expect(Product.where(code: batch_codes).all? { |p| p.status == 'A' }).to be true
    end

    it 'returns errors for invalid status' do
      put :update_batch_status, params: { status: 'X', data: batch_codes.map { |c| { code: c } } }
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to include('Invalid status')
    end
  end
end