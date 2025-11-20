# frozen_string_literal: true

require 'test_helper'

class Quantities::MouldRectangleControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/quantities/mould_rectangle'
    assert_response :success
  end
end
