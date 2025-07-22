require 'test_helper'

class Admin::JourOuvrableAnnuelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_jour_ouvrable_annuel = admin_jour_ouvrable_annuels(:one)
  end

  test "should get index" do
    get admin_jour_ouvrable_annuels_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_jour_ouvrable_annuel_url
    assert_response :success
  end

  test "should create admin_jour_ouvrable_annuel" do
    assert_difference('Admin::JourOuvrableAnnuel.count') do
      post admin_jour_ouvrable_annuels_url, params: { admin_jour_ouvrable_annuel: { mois: @admin_jour_ouvrable_annuel.mois, mois_en_chiffre: @admin_jour_ouvrable_annuel.mois_en_chiffre, nombre_jour_ouvrable: @admin_jour_ouvrable_annuel.nombre_jour_ouvrable } }
    end

    assert_redirected_to admin_jour_ouvrable_annuel_url(Admin::JourOuvrableAnnuel.last)
  end

  test "should show admin_jour_ouvrable_annuel" do
    get admin_jour_ouvrable_annuel_url(@admin_jour_ouvrable_annuel)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_jour_ouvrable_annuel_url(@admin_jour_ouvrable_annuel)
    assert_response :success
  end

  test "should update admin_jour_ouvrable_annuel" do
    patch admin_jour_ouvrable_annuel_url(@admin_jour_ouvrable_annuel), params: { admin_jour_ouvrable_annuel: { mois: @admin_jour_ouvrable_annuel.mois, mois_en_chiffre: @admin_jour_ouvrable_annuel.mois_en_chiffre, nombre_jour_ouvrable: @admin_jour_ouvrable_annuel.nombre_jour_ouvrable } }
    assert_redirected_to admin_jour_ouvrable_annuel_url(@admin_jour_ouvrable_annuel)
  end

  test "should destroy admin_jour_ouvrable_annuel" do
    assert_difference('Admin::JourOuvrableAnnuel.count', -1) do
      delete admin_jour_ouvrable_annuel_url(@admin_jour_ouvrable_annuel)
    end

    assert_redirected_to admin_jour_ouvrable_annuels_url
  end
end
