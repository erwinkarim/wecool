require 'test_helper'

class TrackersControllerTest < ActionController::TestCase
  test "should get track" do
    get :track
    assert_response :success
  end

  test "should get untrack" do
    get :untrack
    assert_response :success
  end

end
