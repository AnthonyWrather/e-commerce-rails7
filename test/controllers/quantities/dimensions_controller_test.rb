# frozen_string_literal: true

require 'test_helper'

class Quantities::DimensionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/quantities/dimensions'
    assert_response :success
  end
end
