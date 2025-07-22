require 'test_helper'

class Admin::TypeRegimesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_regime = admin_type_regimes(:one)
  end

  test "should get index" do
    get admin_type_regimes_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_regime_url
    assert_response :success
  end

  test "should create admin_type_regime" do
    assert_difference('Admin::TypeRegime.count') do
      post admin_type_regimes_url, params: { admin_type_regime: { description: @admin_type_regime.description, nom: @admin_type_regime.nom } }
    end

    assert_redirected_to admin_type_regime_url(Admin::TypeRegime.last)
  end

  test "should show admin_type_regime" do
    get admin_type_regime_url(@admin_type_regime)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_regime_url(@admin_type_regime)
    assert_response :success
  end

  test "should update admin_type_regime" do
    patch admin_type_regime_url(@admin_type_regime), params: { admin_type_regime: { description: @admin_type_regime.description, nom: @admin_type_regime.nom } }
    assert_redirected_to admin_type_regime_url(@admin_type_regime)
  end

  test "should destroy admin_type_regime" do
    assert_difference('Admin::TypeRegime.count', -1) do
      delete admin_type_regime_url(@admin_type_regime)
    end

    assert_redirected_to admin_type_regimes_url
  end
end
