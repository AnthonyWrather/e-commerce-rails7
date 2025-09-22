# frozen_string_literal: true

require 'test_helper'

class Quantities::DimensionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get quantities_dimensions_index_url
    assert_response :success
  end
end
