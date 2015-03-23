require '../test_helper'

class PropertiesControllerTest < ActionController::TestCase
  setup do
    @property = properties(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:properties)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create property" do
    assert_difference('Property.count') do
      post :create, property: { area: @property.area, assessed_value: @property.assessed_value, block: @property.block, category: @property.category, city: @property.city, class_code: @property.class_code, country: @property.country, gmaps: @property.gmaps, latitude: @property.latitude, longitude: @property.longitude, neighborhood: @property.neighborhood, parcel: @property.parcel, pin: @property.pin, street: @property.street, subdivision: @property.subdivision, unit: @property.unit, zip: @property.zip }
    end

    assert_redirected_to property_path(assigns(:property))
  end

  test "should show property" do
    get :show, id: @property
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @property
    assert_response :success
  end

  test "should update property" do
    put :update, id: @property, property: { area: @property.area, assessed_value: @property.assessed_value, block: @property.block, category: @property.category, city: @property.city, class_code: @property.class_code, country: @property.country, gmaps: @property.gmaps, latitude: @property.latitude, longitude: @property.longitude, neighborhood: @property.neighborhood, parcel: @property.parcel, pin: @property.pin, street: @property.street, subdivision: @property.subdivision, unit: @property.unit, zip: @property.zip }
    assert_redirected_to property_path(assigns(:property))
  end

  test "should destroy property" do
    assert_difference('Property.count', -1) do
      delete :destroy, id: @property
    end

    assert_redirected_to properties_path
  end
end
