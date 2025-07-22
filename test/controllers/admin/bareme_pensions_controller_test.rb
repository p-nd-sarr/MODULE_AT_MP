require 'test_helper'

class Admin::BaremePensionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_bareme_pension = admin_bareme_pensions(:one)
  end

  test "should get index" do
    get admin_bareme_pensions_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_bareme_pension_url
    assert_response :success
  end

  test "should create admin_bareme_pension" do
    assert_difference('Admin::BaremePension.count') do
      post admin_bareme_pensions_url, params: { admin_bareme_pension: { admin_type_regime_id: @admin_bareme_pension.admin_type_regime_id, date_debut_validite: @admin_bareme_pension.date_debut_validite, date_fin_validite: @admin_bareme_pension.date_fin_validite, valeur_point_annuelle: @admin_bareme_pension.valeur_point_annuelle, valeur_point_bimestrielle: @admin_bareme_pension.valeur_point_bimestrielle, valeur_point_mensuelle: @admin_bareme_pension.valeur_point_mensuelle, valeur_point_trimestrielle: @admin_bareme_pension.valeur_point_trimestrielle } }
    end

    assert_redirected_to admin_bareme_pension_url(Admin::BaremePension.last)
  end

  test "should show admin_bareme_pension" do
    get admin_bareme_pension_url(@admin_bareme_pension)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_bareme_pension_url(@admin_bareme_pension)
    assert_response :success
  end

  test "should update admin_bareme_pension" do
    patch admin_bareme_pension_url(@admin_bareme_pension), params: { admin_bareme_pension: { admin_type_regime_id: @admin_bareme_pension.admin_type_regime_id, date_debut_validite: @admin_bareme_pension.date_debut_validite, date_fin_validite: @admin_bareme_pension.date_fin_validite, valeur_point_annuelle: @admin_bareme_pension.valeur_point_annuelle, valeur_point_bimestrielle: @admin_bareme_pension.valeur_point_bimestrielle, valeur_point_mensuelle: @admin_bareme_pension.valeur_point_mensuelle, valeur_point_trimestrielle: @admin_bareme_pension.valeur_point_trimestrielle } }
    assert_redirected_to admin_bareme_pension_url(@admin_bareme_pension)
  end

  test "should destroy admin_bareme_pension" do
    assert_difference('Admin::BaremePension.count', -1) do
      delete admin_bareme_pension_url(@admin_bareme_pension)
    end

    assert_redirected_to admin_bareme_pensions_url
  end
end
