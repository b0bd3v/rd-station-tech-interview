# frozen_string_literal: true

class MarkCartAsAbandonedJob < ApplicationJob
  INACTIVE_CART_TIME = 3.hours
  ABANDONED_CART_TIME = 7.days

  def perform
    mark_cart_as_abandoned(Time.zone.now - INACTIVE_CART_TIME)
    remove_cart(Time.current - ABANDONED_CART_TIME)
  end

  def mark_cart_as_abandoned(period)
    Cart.where(abandoned_at: nil)
        .where(last_interaction_at: ...period)
        .update_all(abandoned_at: Time.current)
  end

  def remove_cart(period)
    Cart.where(abandoned_at: ...period)
        .destroy_all
  end
end
