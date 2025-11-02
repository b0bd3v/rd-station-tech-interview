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
require 'rails_helper'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

RSpec.describe Cart, type: :model do
  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect do
        shopping_cart.mark_as_abandoned
      end.to change(shopping_cart, :abandoned?).from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change(described_class, :count).by(-1)
    end
  end

  describe 'create_session_token' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'creates a session token' do
      expect(shopping_cart.session_token).to be_present
    end

    it 'creates a unique session token' do
      expect(shopping_cart.session_token).not_to eq(create(:shopping_cart).session_token)
    end
  end
end
