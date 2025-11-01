class AddTotalPriceToCartItem < ActiveRecord::Migration[7.1]
  def change
    add_column :cart_items, :total_price, :float
  end
end
