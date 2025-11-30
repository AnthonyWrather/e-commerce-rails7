# frozen_string_literal: true

class CartCleanupJob < ApplicationJob
  queue_as :default

  def perform
    expired_count = Cart.expired.count
    Rails.logger.info("CartCleanupJob: Found #{expired_count} expired carts to delete")

    Cart.expired.destroy_all

    Rails.logger.info("CartCleanupJob: Deleted #{expired_count} expired carts")
  end
end
