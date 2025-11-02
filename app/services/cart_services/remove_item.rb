module CartServices
  class RemoveItem
    def self.call(cart:, product:)
      item = cart.cart_items.find_by(product_id: product.id)
      raise ActiveRecord::RecordNotFound if item.nil?

      item.destroy!

      cart.total_price = cart.cart_items.sum(:total_price).round(2)
      cart.last_interaction_at = Time.zone.now

      cart.save
    end
  end
end
