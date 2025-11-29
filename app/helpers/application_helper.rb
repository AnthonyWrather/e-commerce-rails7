# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def formatted_price(price)
    return '£0.00' if price.nil? || price.zero?

    # number_to_currency(price / 100.0, unit: "€", separator: ",", delimiter: ".", format: "%n %u")
    number_to_currency(price / 100.0, unit: '£')
  end

  # Generates an image tag with native lazy loading and async decoding.
  # Use for below-the-fold images to improve initial page load performance.
  #
  # @param source [String, ActiveStorage::Blob] Image source path or blob
  # @param options [Hash] Additional options passed to image_tag
  # @return [String] HTML img tag with loading="lazy" and decoding="async"
  #
  # @example
  #   lazy_image_tag(product.images.first, class: "rounded")
  #   lazy_image_tag("placeholder.jpg", alt: "Placeholder")
  def lazy_image_tag(source, options = {})
    options[:loading] ||= 'lazy'
    options[:decoding] ||= 'async'
    image_tag(source, options)
  end
end
