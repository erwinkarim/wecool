require 'test_helper'

class MediasetsControllerTest < ActionController::TestCase
  setup do
    @mediaset = mediasets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mediasets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mediaset" do
    assert_difference('Mediaset.count') do
      post :create, mediaset: { description: @mediaset.description, title: @mediaset.title }
    end

    assert_redirected_to mediaset_path(assigns(:mediaset))
  end

  test "should show mediaset" do
    get :show, id: @mediaset
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mediaset
    assert_response :success
  end

  test "should update mediaset" do
    put :update, id: @mediaset, mediaset: { description: @mediaset.description, title: @mediaset.title }
    assert_redirected_to mediaset_path(assigns(:mediaset))
  end

  test "should destroy mediaset" do
    assert_difference('Mediaset.count', -1) do
      delete :destroy, id: @mediaset
    end

    assert_redirected_to mediasets_path
  end
end
