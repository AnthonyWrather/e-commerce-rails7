# frozen_string_literal: true

require 'test_helper'

class CartCleanupJobTest < ActiveJob::TestCase
  def setup
    @active_cart = carts(:cart_one)
    @expired_cart = carts(:expired_cart)
  end

  test 'deletes expired carts' do
    assert Cart.exists?(@expired_cart.id)

    CartCleanupJob.perform_now

    assert_not Cart.exists?(@expired_cart.id)
  end

  test 'does not delete active carts' do
    assert Cart.exists?(@active_cart.id)

    CartCleanupJob.perform_now

    assert Cart.exists?(@active_cart.id)
  end

  test 'deletes cart items when cart is deleted' do
    expired_cart_item = cart_items(:cart_item_expired)
    assert CartItem.exists?(expired_cart_item.id)

    CartCleanupJob.perform_now

    assert_not CartItem.exists?(expired_cart_item.id)
  end

  test 'job is enqueued with default queue' do
    assert_enqueued_with(queue: 'default') do
      CartCleanupJob.perform_later
    end
  end
end
