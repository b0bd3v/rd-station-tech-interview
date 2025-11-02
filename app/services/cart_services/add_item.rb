# frozen_string_literal: true

module CartServices
  class AddItem
    def self.call(cart:, product:, quantity:)
      item = cart.cart_items.find_by(product_id: product.id)

      if item
        item.quantity = item.quantity + quantity
        item.total_price = item.quantity * item.product.price
        item.save!
      else
        new_item = cart.cart_items.build(product_id: product.id,
                                         quantity: quantity)
        new_item.save!
      end

      cart.last_interaction_at = Time.zone.now
      cart.save
    end
  end
end
