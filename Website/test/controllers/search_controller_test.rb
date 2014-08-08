require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get suggest" do
    get :suggest, format: :json
    assert_response :success
  end

end
