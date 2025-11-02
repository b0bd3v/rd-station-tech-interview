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
class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy

  before_validation :create_session_token, on: :create
  before_save :update_total_price
  before_save :update_last_interaction, if: -> { cart_items.any? }

  def mark_as_abandoned
    update(abandoned_at: Time.current)
  end

  def remove_if_abandoned
    destroy if abandoned?
  end

  def abandoned?
    abandoned_at.present?
  end

  private

  def update_total_price
    self.total_price = cart_items.sum(:total_price).round(2)
  end

  def update_last_interaction
    self.last_interaction_at = Time.zone.now
  end

  def create_session_token
    loop do
      session_token = SecureRandom.hex(16)

      unless Cart.exists?(session_token: session_token)
        self.session_token = session_token
        break
      end
    end
  end
end
