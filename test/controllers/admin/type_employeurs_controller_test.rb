require 'test_helper'

class Admin::TypeEmployeursControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_employeur = admin_type_employeurs(:one)
  end

  test "should get index" do
    get admin_type_employeurs_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_employeur_url
    assert_response :success
  end

  test "should create admin_type_employeur" do
    assert_difference('Admin::TypeEmployeur.count') do
      post admin_type_employeurs_url, params: { admin_type_employeur: { code: @admin_type_employeur.code, description: @admin_type_employeur.description } }
    end

    assert_redirected_to admin_type_employeur_url(Admin::TypeEmployeur.last)
  end

  test "should show admin_type_employeur" do
    get admin_type_employeur_url(@admin_type_employeur)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_employeur_url(@admin_type_employeur)
    assert_response :success
  end

  test "should update admin_type_employeur" do
    patch admin_type_employeur_url(@admin_type_employeur), params: { admin_type_employeur: { code: @admin_type_employeur.code, description: @admin_type_employeur.description } }
    assert_redirected_to admin_type_employeur_url(@admin_type_employeur)
  end

  test "should destroy admin_type_employeur" do
    assert_difference('Admin::TypeEmployeur.count', -1) do
      delete admin_type_employeur_url(@admin_type_employeur)
    end

    assert_redirected_to admin_type_employeurs_url
  end
end
