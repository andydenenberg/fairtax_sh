require 'test_helper'

class ClassCodesControllerTest < ActionController::TestCase
  setup do
    @class_code = class_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:class_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create class_code" do
    assert_difference('ClassCode.count') do
      post :create, class_code: { category: @class_code.category, cc: @class_code.cc, comments: @class_code.comments, description: @class_code.description, orig_desc: @class_code.orig_desc, value: @class_code.value }
    end

    assert_redirected_to class_code_path(assigns(:class_code))
  end

  test "should show class_code" do
    get :show, id: @class_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @class_code
    assert_response :success
  end

  test "should update class_code" do
    put :update, id: @class_code, class_code: { category: @class_code.category, cc: @class_code.cc, comments: @class_code.comments, description: @class_code.description, orig_desc: @class_code.orig_desc, value: @class_code.value }
    assert_redirected_to class_code_path(assigns(:class_code))
  end

  test "should destroy class_code" do
    assert_difference('ClassCode.count', -1) do
      delete :destroy, id: @class_code
    end

    assert_redirected_to class_codes_path
  end
end
