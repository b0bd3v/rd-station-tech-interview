# frozen_string_literal: true

module CartServices
  class Create
    def self.call(cart:, product:, quantity:)
      cart_item = find_or_build_item(cart, product, quantity)
      cart_item.save!
      update_cart_totals(cart)
    end

    def self.find_or_build_item(cart, product, quantity)
      cart_item = cart.cart_items.find_by(product_id: product.id)

      if cart_item.nil?
        cart.cart_items.build(product_id: product.id, quantity: quantity)
      else
        cart_item.quantity += quantity
        cart_item
      end
    end

    def self.update_cart_totals(cart)
      cart.reload
      cart.last_interaction_at = Time.zone.now
      cart.save
    end
  end
end
