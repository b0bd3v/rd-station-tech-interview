module CartServices
  class RemoveItem
    def self.call(cart:, product:)
      item = cart.cart_items.find_by(product_id: product.id)
      raise ActiveRecord::RecordNotFound if item.nil?

      item.destroy!
      cart.last_interaction_at = Time.zone.now

      cart.save
    end
  end
end
