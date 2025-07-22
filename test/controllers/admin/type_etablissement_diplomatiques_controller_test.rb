require 'test_helper'

class Admin::TypeEtablissementDiplomatiquesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_etablissement_diplomatique = admin_type_etablissement_diplomatiques(:one)
  end

  test "should get index" do
    get admin_type_etablissement_diplomatiques_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_etablissement_diplomatique_url
    assert_response :success
  end

  test "should create admin_type_etablissement_diplomatique" do
    assert_difference('Admin::TypeEtablissementDiplomatique.count') do
      post admin_type_etablissement_diplomatiques_url, params: { admin_type_etablissement_diplomatique: { code: @admin_type_etablissement_diplomatique.code, description: @admin_type_etablissement_diplomatique.description } }
    end

    assert_redirected_to admin_type_etablissement_diplomatique_url(Admin::TypeEtablissementDiplomatique.last)
  end

  test "should show admin_type_etablissement_diplomatique" do
    get admin_type_etablissement_diplomatique_url(@admin_type_etablissement_diplomatique)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_etablissement_diplomatique_url(@admin_type_etablissement_diplomatique)
    assert_response :success
  end

  test "should update admin_type_etablissement_diplomatique" do
    patch admin_type_etablissement_diplomatique_url(@admin_type_etablissement_diplomatique), params: { admin_type_etablissement_diplomatique: { code: @admin_type_etablissement_diplomatique.code, description: @admin_type_etablissement_diplomatique.description } }
    assert_redirected_to admin_type_etablissement_diplomatique_url(@admin_type_etablissement_diplomatique)
  end

  test "should destroy admin_type_etablissement_diplomatique" do
    assert_difference('Admin::TypeEtablissementDiplomatique.count', -1) do
      delete admin_type_etablissement_diplomatique_url(@admin_type_etablissement_diplomatique)
    end

    assert_redirected_to admin_type_etablissement_diplomatiques_url
  end
end
