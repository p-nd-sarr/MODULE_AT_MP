require 'test_helper'

class Admin::TypeEtablissementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_etablissement = admin_type_etablissements(:one)
  end

  test "should get index" do
    get admin_type_etablissements_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_etablissement_url
    assert_response :success
  end

  test "should create admin_type_etablissement" do
    assert_difference('Admin::TypeEtablissement.count') do
      post admin_type_etablissements_url, params: { admin_type_etablissement: { code: @admin_type_etablissement.code, description: @admin_type_etablissement.description } }
    end

    assert_redirected_to admin_type_etablissement_url(Admin::TypeEtablissement.last)
  end

  test "should show admin_type_etablissement" do
    get admin_type_etablissement_url(@admin_type_etablissement)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_etablissement_url(@admin_type_etablissement)
    assert_response :success
  end

  test "should update admin_type_etablissement" do
    patch admin_type_etablissement_url(@admin_type_etablissement), params: { admin_type_etablissement: { code: @admin_type_etablissement.code, description: @admin_type_etablissement.description } }
    assert_redirected_to admin_type_etablissement_url(@admin_type_etablissement)
  end

  test "should destroy admin_type_etablissement" do
    assert_difference('Admin::TypeEtablissement.count', -1) do
      delete admin_type_etablissement_url(@admin_type_etablissement)
    end

    assert_redirected_to admin_type_etablissements_url
  end
end
