# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def formatted_price(price)
    return '£0.00' if price.nil? || price.zero?

    # number_to_currency(price / 100.0, unit: "€", separator: ",", delimiter: ".", format: "%n %u")
    number_to_currency(price / 100.0, unit: '£')
  end
end
