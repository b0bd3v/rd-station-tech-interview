module CartServices
  class Create
    def self.call(cart:, product:, quantity:)
      cart_item = cart.cart_items.find_by(product_id: product.id)

      if cart_item.nil?
        cart_item = cart.cart_items.build({ product_id: product.id, quantity: quantity })
      else
        cart_item.quantity = cart_item.quantity + quantity
      end

      cart_item.save!

      cart.reload
      cart.total_price = cart.cart_items.sum(:total_price).round(2)
      cart.last_interaction_at = Time.zone.now

      cart.save
    end
  end
end
