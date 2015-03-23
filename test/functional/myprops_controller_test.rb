require 'test_helper'

class MypropsControllerTest < ActionController::TestCase
  setup do
    @myprop = myprops(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:myprops)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create myprop" do
    assert_difference('Myprop.count') do
      post :create, myprop: { city: @myprop.city, pin: @myprop.pin, status: @myprop.status, street: @myprop.street, user_id: @myprop.user_id }
    end

    assert_redirected_to myprop_path(assigns(:myprop))
  end

  test "should show myprop" do
    get :show, id: @myprop
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @myprop
    assert_response :success
  end

  test "should update myprop" do
    put :update, id: @myprop, myprop: { city: @myprop.city, pin: @myprop.pin, status: @myprop.status, street: @myprop.street, user_id: @myprop.user_id }
    assert_redirected_to myprop_path(assigns(:myprop))
  end

  test "should destroy myprop" do
    assert_difference('Myprop.count', -1) do
      delete :destroy, id: @myprop
    end

    assert_redirected_to myprops_path
  end
end
