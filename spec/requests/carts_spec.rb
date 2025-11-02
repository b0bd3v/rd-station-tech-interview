# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/carts', type: :request do
  describe 'GET /cart' do
    let!(:cart) { create(:cart) }

    before { get '/cart', headers: { 'Cart-Token' => cart.session_token } }

    context 'when cart exists' do
      it 'returns a 200 status code' do
        expect(response).to have_http_status(200)
      end

      it 'returns the expected JSON structure' do
        expect(response.parsed_body).to include('id' => be_a(Integer),
                                                'products' => be_an(Array),
                                                'total_price' => be_a(Float))
      end
    end

    context 'when cart does not exist' do
      it 'returns a 404 status code' do
        get '/cart', headers: { 'Cart-Token' => 'test' }

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /cart' do
    let(:product) { create(:product, name: 'Test Product', price: 10.0) }

    context 'when adding a item without a cart' do
      before { post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json }

      it 'creates a new cart' do
        expect(Cart.count).to eq(1)
      end

      it 'counts the number of items in the cart' do
        expect(CartItem.count).to eq(1)
        expect(CartItem.first.quantity).to eq(3)
      end

      it 'returns the cart token' do
        expect(response.headers['Cart-Token']).to eq(Cart.last.session_token)
      end
    end

    context 'when adding a item with a cart' do
      let!(:cart) { create(:cart) }

      it 'updates the quantity of item' do
        payload = { product_id: product.id, quantity: 3 }

        post '/cart', params: payload, headers: { 'Cart-Token' => cart.reload.session_token }, as: :json

        expect(Cart.first.session_token).to eq(cart.session_token)
      end
    end

    context 'when item is already in the cart' do
      let!(:cart) { create(:cart) }
      let!(:product) { create(:product, name: 'Test Product', price: 10.0) }

      before do
        create(:cart_item, cart: cart, product: product, quantity: 3, total_price: 30.0)
        post '/cart', headers: { 'Cart-Token' => Cart.last.session_token },
                      params: { product_id: product.id, quantity: 3 }, as: :json
      end

      it 'updates the quantity of item' do
        expect(CartItem.first.quantity).to eq(6)
        expect(CartItem.first.total_price).to eq(60.0)
      end
    end

    context 'when creating a cart with products' do
      let!(:product_first) { create(:product, name: 'Product 1', price: 1.99) }
      let!(:product_last) { create(:product, name: 'Product 2', price: 1.99) }
      let(:product_first_body) do
        {
          'id' => product_first.id,
          'name' => 'Product 1',
          'quantity' => 2,
          'unit_price' => 1.99,
          'total_price' => 3.98
        }
      end

      let(:product_last_body) do
        {
          'id' => product_last.id,
          'name' => 'Product 2',
          'quantity' => 2,
          'unit_price' => 1.99,
          'total_price' => 3.98
        }
      end

      it 'returns the expected JSON structure' do
        post '/cart', params: { product_id: product_first.id, quantity: 2 }, as: :json
        post '/cart', headers: { 'Cart-Token' => response.headers['Cart-Token'] },
                      params: { product_id: product_last.id, quantity: 2 }, as: :json

        expect(response.parsed_body)
          .to include('id' => be_a(Integer),
                      'products' => contain_exactly(include(product_first_body), include(product_last_body)),
                      'total_price' => 7.96)
      end
    end

    context 'when cart validation fails' do
      before do
        allow(CartServices::Create).to receive(:call).and_return(false)
      end

      it 'returns a 422 status' do
        post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when product not exist' do
      it 'returns a 404 status' do
        post '/cart', params: { product_id: 999, quantity: 3 }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when an unexpedted error' do
      before do
        allow(CartServices::Create).to receive(:call).and_raise(StandardError, 'Error message')
      end

      it 'returns a 500 status' do
        post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json

        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  describe 'POST /cart/add_item' do
    let!(:product) { create(:product, name: 'Test Product', price: 10.0) }
    let!(:cart) { create(:cart) }

    it 'adds item to the cart' do
      post '/cart/add_item', headers: { 'Cart-Token' => cart.session_token },
                             params: { product_id: product.id, quantity: 3 }, as: :json

      expect(CartItem.count).to eq(1)
    end

    it 'adds existing item to the cart' do
      cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)

      post '/cart/add_item', headers: { 'Cart-Token' => cart.session_token },
                             params: { product_id: product.id, quantity: 3 }, as: :json

      expect(CartItem.first.quantity).to eq(5)
      expect(CartItem.first.total_price).to eq(50.0)
    end

    context 'when product not exist' do
      it 'returns a 404 status' do
        post '/cart/add_item', params: { product_id: 999, quantity: 3 }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when unprocessable_entity' do
      before do
        allow(CartServices::AddItem).to receive(:call).and_return(false)
      end

      it 'returns a 422 status' do
        post '/cart/add_item', headers: { 'Cart-Token' => cart.session_token },
                               params: { product_id: product.id, quantity: 0 }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when unexpedted error' do
      before do
        allow(CartServices::AddItem).to receive(:call).and_raise(StandardError, 'Error message')
      end

      it 'returns a 500 status' do
        post '/cart/add_item', headers: { 'Cart-Token' => cart.session_token },
                               params: { product_id: product.id, quantity: 3 }, as: :json

        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  describe 'DELETE /cart/:id' do
    let(:product) { create(:product, name: 'Test Product', price: 10.0) }
    let(:cart) { create(:cart) }
    let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

    it 'removes item from the cart' do
      create(:cart_item, cart: cart, product: product, quantity: 2)

      delete "/cart/#{product.id}", headers: { 'Cart-Token' => cart.session_token }, as: :json

      expect(CartItem.count).to eq(0)
    end

    context 'when unprocessable_entity' do
      before do
        allow(CartServices::RemoveItem).to receive(:call).and_return(false)
      end

      it 'returns a 422 status' do
        delete "/cart/#{product.id}", headers: { 'Cart-Token' => cart.session_token }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when item not exist' do
      it 'returns a 404 status' do
        delete "/cart/#{999}", headers: { 'Cart-Token' => cart.session_token }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when cart not exist' do
      it 'returns a 404 status' do
        delete "/cart/#{product.id}", headers: { 'Cart-Token' => '000000000' }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when unexpedted error' do
      before do
        allow(CartServices::RemoveItem).to receive(:call).and_raise(StandardError, 'Error message')
      end

      it 'returns a 500 status' do
        delete "/cart/#{product.id}", headers: { 'Cart-Token' => cart.session_token }, as: :json

        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
