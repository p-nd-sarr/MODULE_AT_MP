require 'test_helper'

class Admin::MouvementTravailFinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_mouvement_travail_fin = admin_mouvement_travail_fins(:one)
  end

  test "should get index" do
    get admin_mouvement_travail_fins_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_mouvement_travail_fin_url
    assert_response :success
  end

  test "should create admin_mouvement_travail_fin" do
    assert_difference('Admin::MouvementTravailFin.count') do
      post admin_mouvement_travail_fins_url, params: { admin_mouvement_travail_fin: { code: @admin_mouvement_travail_fin.code, description: @admin_mouvement_travail_fin.description } }
    end

    assert_redirected_to admin_mouvement_travail_fin_url(Admin::MouvementTravailFin.last)
  end

  test "should show admin_mouvement_travail_fin" do
    get admin_mouvement_travail_fin_url(@admin_mouvement_travail_fin)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_mouvement_travail_fin_url(@admin_mouvement_travail_fin)
    assert_response :success
  end

  test "should update admin_mouvement_travail_fin" do
    patch admin_mouvement_travail_fin_url(@admin_mouvement_travail_fin), params: { admin_mouvement_travail_fin: { code: @admin_mouvement_travail_fin.code, description: @admin_mouvement_travail_fin.description } }
    assert_redirected_to admin_mouvement_travail_fin_url(@admin_mouvement_travail_fin)
  end

  test "should destroy admin_mouvement_travail_fin" do
    assert_difference('Admin::MouvementTravailFin.count', -1) do
      delete admin_mouvement_travail_fin_url(@admin_mouvement_travail_fin)
    end

    assert_redirected_to admin_mouvement_travail_fins_url
  end
end
