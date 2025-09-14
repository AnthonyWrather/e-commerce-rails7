# frozen_string_literal: true

require 'test_helper'

class Admin::ImagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get destroy' do
    get admin_images_destroy_url
    assert_response :success
  end
end
