# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :find_or_create_cart

  def create
    cart_item = @cart.cart_items.find_by(product_id: item_params[:product_id])

    if cart_item.nil?
      cart_item = @cart.cart_items.build(product_id: item_params[:product_id], quantity: item_params[:quantity])
    else
      cart_item.quantity = cart_item.quantity + item_params[:quantity]
    end

    cart_item.total_price = cart_item.quantity * cart_item.product.price
    @cart.total_price = @cart.cart_items.sum(:total_price)

    if @cart.save!
      render :create, status: :created
    else
      render json: cart_item.errors, status: :unprocessable_entity
    end
  end

  private

  def find_or_create_cart
    @cart = Cart.find_by(session_token: request.headers['Cart-Token'])

    @cart = Cart.create if @cart.nil?
  end

  def item_params
    params.permit(:product_id, :quantity)
  end
end
