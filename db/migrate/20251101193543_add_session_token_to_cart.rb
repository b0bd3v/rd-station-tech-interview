class AddSessionTokenToCart < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :session_token, :string
    add_index :carts, :session_token
  end
end
