# frozen_string_literal: true

# == Schema Information
#
# Table name: carts
#
#  id                  :bigint           not null, primary key
#  abandoned_at        :datetime
#  last_interaction_at :datetime
#  total_price         :decimal(17, 2)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Cart < ApplicationRecord
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }

  has_many :cart_items, dependent: :destroy

  def mark_as_abandoned
    update(abandoned_at: Time.current)
  end

  def remove_if_abandoned
    destroy if abandoned?
  end

  def abandoned?
    abandoned_at.present?
  end
end
