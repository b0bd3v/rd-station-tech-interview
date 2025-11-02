# frozen_string_literal: true

require 'rails_helper'

describe MarkCartAsAbandonedJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  around { |example| travel_to(Time.zone.parse('2025-11-02 12:00:00')) { example.run } }

  it 'set abandoned cart' do
    cart = create(:cart, last_interaction_at: 3.hours.ago - 1.second)
    described_class.perform_now

    expect(cart.reload.abandoned?).to be true
  end

  it 'does not abandoned cart' do
    cart = create(:cart, last_interaction_at: 3.hours.ago)
    described_class.perform_now

    expect(cart.reload.abandoned?).to be false
  end

  it 'remove cart' do
    cart = create(:cart, abandoned_at: 7.days.ago - 1.second)
    described_class.perform_now

    expect(Cart.exists?(cart.id)).to be false
  end

  it 'does not remove cart' do
    cart = create(:cart, abandoned_at: 7.days.ago)
    described_class.perform_now

    expect(Cart.exists?(cart.id)).to be true
  end
end
