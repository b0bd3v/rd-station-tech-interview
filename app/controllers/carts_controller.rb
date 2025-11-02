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
    product = Product.find(item_params[:product_id])
    result = CartServices::Create.call(cart: @cart, product: product, quantity: item_params[:quantity])

    if result
      render json: @cart, serializer: ::CartSerializer, status: :created
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def add_item
    find_cart_by_token
    product = Product.find(item_params[:product_id])
    process_add_item(product)
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def remove_item
    @cart = Cart.find_by(session_token: request.headers['Cart-Token'])
    raise ActiveRecord::RecordNotFound unless @cart

    product = Product.find(item_params[:product_id])
    result = CartServices::RemoveItem.call(cart: @cart, product: product)

    return render json: @cart, serializer: ::CartSerializer, status: :created if result

    render json: @cart.errors, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def find_or_create_cart
    @cart = Cart.find_by(session_token: request.headers['Cart-Token'])

    return if @cart

    @cart = Cart.new(total_price: 0)
    @cart.save!
  end

  def cart_token
    response.set_header 'Cart-Token', @cart.session_token if @cart
  end

  def find_cart_by_token
    @cart = Cart.find_by(session_token: request.headers['Cart-Token'])
    raise ActiveRecord::RecordNotFound unless @cart
  end

  def process_add_item(product)
    result = CartServices::AddItem.call(cart: @cart, product: product, quantity: item_params[:quantity])

    if result
      render json: @cart, serializer: ::CartSerializer, status: :created
    else
      render json: @cart.errors, status: :unprocessable_entity
    end
  end

  def item_params
    params.permit(:product_id, :quantity)
  end
end
