# frozen_string_literal: true

class Admin::ImagesController < ApplicationController
  def destroy
    # Get the Product ID and the Image ID from the parameters
    product = Product.find(params[:product_id].to_i)
    image = product.images.find(params[:id].to_i)
    product.images.delete(image)
    redirect_to edit_admin_product_path(product), notice: 'Image was successfully deleted.'
  end
end
