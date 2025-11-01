class CartSerializer < ActiveModel::Serializer
  attributes :id, :products, :total_price

  def products
    object.cart_items.map do |cart_item|
      {
        id: cart_item.product_id,
        name: cart_item.product.name,
        quantity: cart_item.quantity,
        unit_price: cart_item.product.price.to_f,
        total_price: cart_item.total_price
      }
    end
  end

  def total_price
    object.cart_items.sum(:total_price)
  end
end
