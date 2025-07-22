require 'test_helper'

class Admin::BaremesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_bareme = admin_baremes(:one)
  end

  test "should get index" do
    get admin_baremes_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_bareme_url
    assert_response :success
  end

  test "should create admin_bareme" do
    assert_difference('Admin::Bareme.count') do
      post admin_baremes_url, params: { admin_bareme: { admin_type_regime_id: @admin_bareme.admin_type_regime_id, date_debut_validite: @admin_bareme.date_debut_validite, date_fin_validite: @admin_bareme.date_fin_validite, periode: @admin_bareme.periode, plafond_salaire: @admin_bareme.plafond_salaire, taux: @admin_bareme.taux, valeur_point: @admin_bareme.valeur_point } }
    end

    assert_redirected_to admin_bareme_url(Admin::Bareme.last)
  end

  test "should show admin_bareme" do
    get admin_bareme_url(@admin_bareme)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_bareme_url(@admin_bareme)
    assert_response :success
  end

  test "should update admin_bareme" do
    patch admin_bareme_url(@admin_bareme), params: { admin_bareme: { admin_type_regime_id: @admin_bareme.admin_type_regime_id, date_debut_validite: @admin_bareme.date_debut_validite, date_fin_validite: @admin_bareme.date_fin_validite, periode: @admin_bareme.periode, plafond_salaire: @admin_bareme.plafond_salaire, taux: @admin_bareme.taux, valeur_point: @admin_bareme.valeur_point } }
    assert_redirected_to admin_bareme_url(@admin_bareme)
  end

  test "should destroy admin_bareme" do
    assert_difference('Admin::Bareme.count', -1) do
      delete admin_bareme_url(@admin_bareme)
    end

    assert_redirected_to admin_baremes_url
  end
end
