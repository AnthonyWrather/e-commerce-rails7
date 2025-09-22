# frozen_string_literal: true

require 'test_helper'

class Quantities::MouldRectangleControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get quantities_mould_rectangle_index_url
    assert_response :success
  end
end
