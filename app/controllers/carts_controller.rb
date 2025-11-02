# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :find_or_create_cart, only: :create
  after_action :cart_token

  def show
    @cart = Cart.find_by(session_token: request.headers['Cart-Token'])

    if @cart.nil?
      render json: {}, status: :not_found
    else
      render json: @cart, serializer: ::CartSerializer
    end
  end

  def create
    cart_item = @cart.cart_items.find_by(product_id: item_params[:product_id])

    if cart_item.nil?
      cart_item = @cart.cart_items.build(product_id: item_params[:product_id], quantity: item_params[:quantity])
    else
      cart_item.quantity = cart_item.quantity + item_params[:quantity]
    end

    cart_item.total_price = cart_item.quantity * cart_item.product.price
    @cart.total_price = @cart.cart_items.sum(:total_price)

    if @cart.save
      render json: @cart, serializer: ::CartSerializer, status: :created
    else
      render json: cart_item.errors, status: :unprocessable_entity
    end
  end

  def add_item
    @cart = Cart.find_by(session_token: request.headers['Cart-Token'])
    return render json: {}, status: :not_found unless @cart

    product = Product.find(item_params[:product_id])
    return render json: {}, status: :not_found unless product

    item = @cart.cart_items.find_by(product_id: product.id)

    if item
      item.quantity = item.quantity + item_params[:quantity]
      item.total_price = item.quantity * item.product.price
      item.save!
    else
      new_item = @cart.cart_items.build(product_id: product.id,
                                        quantity: item_params[:quantity],
                                        total_price: item_params[:quantity] * product.price)
      new_item.save!
    end

    @cart.total_price = @cart.cart_items.sum(:total_price)
    @cart.last_interaction_at = Time.now

    if @cart.save
      render json: @cart, serializer: ::CartSerializer, status: :created
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  def remove_item
    @cart = Cart.find_by(session_token: request.headers['Cart-Token'])

    return render json: {}, status: :not_found unless @cart

    item = @cart.cart_items.find_by(product_id: item_params[:product_id])
    return render json: {}, status: :not_found unless item

    item.destroy!
    @cart.total_price = @cart.cart_items.sum(:total_price)
    @cart.last_interaction_at = Time.now

    if @cart.save
      render json: @cart, serializer: ::CartSerializer, status: :created
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  private

  def find_or_create_cart
    @cart = Cart.find_by(session_token: request.headers['Cart-Token'])

    @cart = Cart.create if @cart.nil?
  end

  def cart_token
    response.set_header 'Cart-Token', @cart.session_token
  end

  def item_params
    params.permit(:product_id, :quantity)
  end
end
