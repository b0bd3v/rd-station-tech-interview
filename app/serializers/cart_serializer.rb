# frozen_string_literal: true

# == Schema Information
#
# Table name: carts
#
#  id                  :bigint           not null, primary key
#  abandoned_at        :datetime
#  last_interaction_at :datetime
#  session_token       :string
#  total_price         :decimal(17, 2)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_carts_on_session_token  (session_token)
#
class CartSerializer < ActiveModel::Serializer
  attributes :id, :products, :total_price

  def products
    object.cart_items.map do |cart_item|
      {
        id: cart_item.product_id,
        name: cart_item.product.name,
        quantity: cart_item.quantity,
        unit_price: cart_item.product.price.to_f,
        total_price: cart_item.total_price.round(2)
      }
    end
  end

  def total_price
    object.cart_items.sum(:total_price).round(2)
  end
end
