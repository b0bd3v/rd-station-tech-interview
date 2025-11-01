# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/carts', type: :request do
  describe 'POST /cart' do
    let(:product) { Product.create(name: 'Test Product', price: 10.0) }

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
      let!(:cart) { Cart.create! total_price: 0 }

      it 'updates the quantity of item' do
        payload = { product_id: product.id, quantity: 3 }

        post '/cart', params: payload, headers: { 'Cart-Token' => cart.reload.session_token }, as: :json

        expect(Cart.first.session_token).to eq(cart.session_token)
      end
    end

    context 'when creating a cart with products' do
      let!(:product_first) { Product.create(name: 'Product 1', price: 1.99) }
      let!(:product_last) { Product.create(name: 'Product 2', price: 1.99) }
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
  end
end
