require 'test_helper'

class DetailsControllerTest < ActionController::TestCase
  setup do
    @detail = details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create detail" do
    assert_difference('Detail.count') do
      post :create, detail: { age: @detail.age, apartments: @detail.apartments, attic: @detail.attic, basement: @detail.basement, building_size: @detail.building_size, building_value_ratio: @detail.building_value_ratio, central_air: @detail.central_air, certified: @detail.certified, city: @detail.city, classification: @detail.classification, current_building: @detail.current_building, current_land: @detail.current_land, current_value: @detail.current_value, current_year: @detail.current_year, description: @detail.description, ext_construction: @detail.ext_construction, fireplace: @detail.fireplace, full_bath: @detail.full_bath, garage: @detail.garage, half_bath: @detail.half_bath, land_size: @detail.land_size, land_value_ratio: @detail.land_value_ratio, neighborhood: @detail.neighborhood, pin: @detail.pin, prior_building: @detail.prior_building, prior_land: @detail.prior_land, prior_value: @detail.prior_value, prior_year: @detail.prior_year, property_id: @detail.property_id, res_type: @detail.res_type, tax_code: @detail.tax_code, township: @detail.township, use: @detail.use }
    end

    assert_redirected_to detail_path(assigns(:detail))
  end

  test "should show detail" do
    get :show, id: @detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @detail
    assert_response :success
  end

  test "should update detail" do
    put :update, id: @detail, detail: { age: @detail.age, apartments: @detail.apartments, attic: @detail.attic, basement: @detail.basement, building_size: @detail.building_size, building_value_ratio: @detail.building_value_ratio, central_air: @detail.central_air, certified: @detail.certified, city: @detail.city, classification: @detail.classification, current_building: @detail.current_building, current_land: @detail.current_land, current_value: @detail.current_value, current_year: @detail.current_year, description: @detail.description, ext_construction: @detail.ext_construction, fireplace: @detail.fireplace, full_bath: @detail.full_bath, garage: @detail.garage, half_bath: @detail.half_bath, land_size: @detail.land_size, land_value_ratio: @detail.land_value_ratio, neighborhood: @detail.neighborhood, pin: @detail.pin, prior_building: @detail.prior_building, prior_land: @detail.prior_land, prior_value: @detail.prior_value, prior_year: @detail.prior_year, property_id: @detail.property_id, res_type: @detail.res_type, tax_code: @detail.tax_code, township: @detail.township, use: @detail.use }
    assert_redirected_to detail_path(assigns(:detail))
  end

  test "should destroy detail" do
    assert_difference('Detail.count', -1) do
      delete :destroy, id: @detail
    end

    assert_redirected_to details_path
  end
end
