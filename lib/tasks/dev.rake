# frozen_string_literal: true
if Rails.env.development?
  namespace :dev do
    desc 'Created example carts'
    task carts: :environment do
      20.times do
        abandoned_at = rand(3..53).days.ago
        last_interaction_at = abandoned_at - rand(1..48).hours

        cart = Cart.find_or_create_by!(id: rand(3..53)) do |c|
          c.abandoned_at = abandoned_at
          c.last_interaction_at = last_interaction_at
        end

        Product.all.sample(3).each do |product|
          CartItem.find_or_create_by!(cart: cart, product: product) do |ci|
            ci.quantity = rand(1..4)
          end
        end
      end
    end
  end
end
