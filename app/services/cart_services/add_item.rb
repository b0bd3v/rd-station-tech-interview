# frozen_string_literal: true

module CartServices
  class AddItem
    def self.call(cart:, product:, quantity:)
      find_or_create(cart, product, quantity)
      update_cart_last_interaction(cart)
    end

    def self.find_or_create(cart, product, quantity)
      item = cart.cart_items.find_by(product_id: product.id)

      if item
        update_existing_item(item, quantity)
      else
        create_new_item(cart, product, quantity)
      end
    end

    def self.update_existing_item(item, quantity)
      item.quantity = quantity + item.quantity
      item.total_price = item.quantity * item.product.price
      item.save!

      item
    end

    def self.create_new_item(cart, product, quantity)
      cart.cart_items.create!(product_id: product.id, quantity: quantity)
    end

    def self.update_cart_last_interaction(cart)
      cart.last_interaction_at = Time.zone.now

      cart.save
    end
  end
end
