require 'test_helper'

class PosControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create po" do
    assert_difference('Po.count') do
      post :create, :po => { }
    end

    assert_redirected_to po_path(assigns(:po))
  end

  test "should show po" do
    get :show, :id => pos(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => pos(:one).to_param
    assert_response :success
  end

  test "should update po" do
    put :update, :id => pos(:one).to_param, :po => { }
    assert_redirected_to po_path(assigns(:po))
  end

  test "should destroy po" do
    assert_difference('Po.count', -1) do
      delete :destroy, :id => pos(:one).to_param
    end

    assert_redirected_to pos_path
  end
end
