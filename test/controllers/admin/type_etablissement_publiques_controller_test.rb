require 'test_helper'

class Admin::TypeEtablissementPubliquesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_etablissement_publique = admin_type_etablissement_publiques(:one)
  end

  test "should get index" do
    get admin_type_etablissement_publiques_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_etablissement_publique_url
    assert_response :success
  end

  test "should create admin_type_etablissement_publique" do
    assert_difference('Admin::TypeEtablissementPublique.count') do
      post admin_type_etablissement_publiques_url, params: { admin_type_etablissement_publique: { code: @admin_type_etablissement_publique.code, description: @admin_type_etablissement_publique.description } }
    end

    assert_redirected_to admin_type_etablissement_publique_url(Admin::TypeEtablissementPublique.last)
  end

  test "should show admin_type_etablissement_publique" do
    get admin_type_etablissement_publique_url(@admin_type_etablissement_publique)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_etablissement_publique_url(@admin_type_etablissement_publique)
    assert_response :success
  end

  test "should update admin_type_etablissement_publique" do
    patch admin_type_etablissement_publique_url(@admin_type_etablissement_publique), params: { admin_type_etablissement_publique: { code: @admin_type_etablissement_publique.code, description: @admin_type_etablissement_publique.description } }
    assert_redirected_to admin_type_etablissement_publique_url(@admin_type_etablissement_publique)
  end

  test "should destroy admin_type_etablissement_publique" do
    assert_difference('Admin::TypeEtablissementPublique.count', -1) do
      delete admin_type_etablissement_publique_url(@admin_type_etablissement_publique)
    end

    assert_redirected_to admin_type_etablissement_publiques_url
  end
end
