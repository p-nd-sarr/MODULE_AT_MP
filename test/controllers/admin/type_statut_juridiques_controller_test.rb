require 'test_helper'

class Admin::TypeStatutJuridiquesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_statut_juridique = admin_type_statut_juridiques(:one)
  end

  test "should get index" do
    get admin_type_statut_juridiques_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_statut_juridique_url
    assert_response :success
  end

  test "should create admin_type_statut_juridique" do
    assert_difference('Admin::TypeStatutJuridique.count') do
      post admin_type_statut_juridiques_url, params: { admin_type_statut_juridique: { code: @admin_type_statut_juridique.code, description: @admin_type_statut_juridique.description } }
    end

    assert_redirected_to admin_type_statut_juridique_url(Admin::TypeStatutJuridique.last)
  end

  test "should show admin_type_statut_juridique" do
    get admin_type_statut_juridique_url(@admin_type_statut_juridique)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_statut_juridique_url(@admin_type_statut_juridique)
    assert_response :success
  end

  test "should update admin_type_statut_juridique" do
    patch admin_type_statut_juridique_url(@admin_type_statut_juridique), params: { admin_type_statut_juridique: { code: @admin_type_statut_juridique.code, description: @admin_type_statut_juridique.description } }
    assert_redirected_to admin_type_statut_juridique_url(@admin_type_statut_juridique)
  end

  test "should destroy admin_type_statut_juridique" do
    assert_difference('Admin::TypeStatutJuridique.count', -1) do
      delete admin_type_statut_juridique_url(@admin_type_statut_juridique)
    end

    assert_redirected_to admin_type_statut_juridiques_url
  end
end
