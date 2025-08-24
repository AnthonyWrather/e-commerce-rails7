# frozen_string_literal: true

class ProductStock < ApplicationRecord
  belongs_to :product
end
