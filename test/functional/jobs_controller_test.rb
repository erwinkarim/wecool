require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  test "should get pending" do
    get :pending
    assert_response :success
  end

end
