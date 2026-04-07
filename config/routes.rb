Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :products do
        collection do
          post :single, action: :create_single       # POST /api/v1/products/single
          post :batch,  action: :create_batch        # POST /api/v1/products/batch
          put  :batch,  action: :update_batch_status # PUT /api/v1/products/batch
        end
      end

      resources :orders

      resources :users, only: [:create, :show]

      post   '/login',  to: 'sessions#create'

      resource :cart do
        post   'add',    to: 'carts#add_item'
        post   'checkout', to: 'carts#checkout'
        put    'update', to: 'carts#update_item'
        delete 'remove', to: 'carts#remove_item'
      end
    end
  end
end
