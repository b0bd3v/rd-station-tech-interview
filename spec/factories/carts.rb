# frozen_string_literal: true

# == Schema Information
#
# Table name: carts
#
#  id                  :bigint           not null, primary key
#  abandoned_at        :datetime
#  last_interaction_at :datetime
#  session_token       :string
#  total_price         :decimal(17, 2)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_carts_on_session_token  (session_token)
#
FactoryBot.define do
  factory :cart do
    total_price { 0.0 }
    last_interaction_at { Time.current }
    abandoned_at { nil }

    factory :shopping_cart, parent: :cart
  end
end
