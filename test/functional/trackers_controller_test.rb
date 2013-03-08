require 'test_helper'

class TrackersControllerTest < ActionController::TestCase
  setup do
    @tracker = trackers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trackers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tracker" do
    assert_difference('Tracker.count') do
      post :create, tracker: { object_id: @tracker.object_id, object_type: @tracker.object_type, relationship: @tracker.relationship }
    end

    assert_redirected_to tracker_path(assigns(:tracker))
  end

  test "should show tracker" do
    get :show, id: @tracker
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tracker
    assert_response :success
  end

  test "should update tracker" do
    put :update, id: @tracker, tracker: { object_id: @tracker.object_id, object_type: @tracker.object_type, relationship: @tracker.relationship }
    assert_redirected_to tracker_path(assigns(:tracker))
  end

  test "should destroy tracker" do
    assert_difference('Tracker.count', -1) do
      delete :destroy, id: @tracker
    end

    assert_redirected_to trackers_path
  end
end
