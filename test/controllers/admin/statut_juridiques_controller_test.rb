require 'test_helper'

class Admin::StatutJuridiquesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_statut_juridique = admin_statut_juridiques(:one)
  end

  test "should get index" do
    get admin_statut_juridiques_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_statut_juridique_url
    assert_response :success
  end

  test "should create admin_statut_juridique" do
    assert_difference('Admin::StatutJuridique.count') do
      post admin_statut_juridiques_url, params: { admin_statut_juridique: { code: @admin_statut_juridique.code, description: @admin_statut_juridique.description } }
    end

    assert_redirected_to admin_statut_juridique_url(Admin::StatutJuridique.last)
  end

  test "should show admin_statut_juridique" do
    get admin_statut_juridique_url(@admin_statut_juridique)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_statut_juridique_url(@admin_statut_juridique)
    assert_response :success
  end

  test "should update admin_statut_juridique" do
    patch admin_statut_juridique_url(@admin_statut_juridique), params: { admin_statut_juridique: { code: @admin_statut_juridique.code, description: @admin_statut_juridique.description } }
    assert_redirected_to admin_statut_juridique_url(@admin_statut_juridique)
  end

  test "should destroy admin_statut_juridique" do
    assert_difference('Admin::StatutJuridique.count', -1) do
      delete admin_statut_juridique_url(@admin_statut_juridique)
    end

    assert_redirected_to admin_statut_juridiques_url
  end
end
