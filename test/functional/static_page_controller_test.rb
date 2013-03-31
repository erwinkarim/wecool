require 'test_helper'

class StaticPageControllerTest < ActionController::TestCase
  test "should get tour" do
    get :tour
    assert_response :success
  end

end
