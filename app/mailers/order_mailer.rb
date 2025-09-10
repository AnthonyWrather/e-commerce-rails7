# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.new_order_email.subject
  #
  def new_order_email(order)
    @greeting = 'You placed an order.'
    @order = order

    mail(to: @order.customer_email, subject: 'Your order has been received')
  end
end
