# frozen_string_literal: true

# == Schema Information
#
# Table name: cart_items
#
#  id         :bigint           not null, primary key
#  quantity   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cart_id    :bigint           not null
#  product_id :bigint           not null
#
# Indexes
#
#  index_cart_items_on_cart_id     (cart_id)
#  index_cart_items_on_product_id  (product_id)
#
# Foreign Keys
#
#  fk_rails_...  (cart_id => carts.id)
#  fk_rails_...  (product_id => products.id)
#
require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let!(:cart) { create(:cart) }
  let!(:product) { create(:product, price: 20) }

  context 'when validating' do
    it 'raises when quantity is not greater than 0' do
      expect do
        described_class.create!(cart: cart, product: product, quantity: 0)
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Quantity must be greater than 0')
    end
  end

  context 'when calculating total price' do
    it 'calculates total price' do
      cart_item = described_class.create(cart: cart, product: product, quantity: 2)

      expect(cart_item.total_price).to eq(40)
    end
  end
end
