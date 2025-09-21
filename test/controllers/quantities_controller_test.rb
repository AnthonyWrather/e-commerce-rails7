require "test_helper"

class QuantitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get quantities_index_url
    assert_response :success
  end
end
