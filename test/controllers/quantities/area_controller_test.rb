# frozen_string_literal: true

require 'test_helper'

class Quantities::AreaControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/quantities/area'
    assert_response :success
  end
end
