require 'test_helper'

class Admin::TypeEtatCivilsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_etat_civil = admin_type_etat_civils(:one)
  end

  test "should get index" do
    get admin_type_etat_civils_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_etat_civil_url
    assert_response :success
  end

  test "should create admin_type_etat_civil" do
    assert_difference('Admin::TypeEtatCivil.count') do
      post admin_type_etat_civils_url, params: { admin_type_etat_civil: { code: @admin_type_etat_civil.code, description: @admin_type_etat_civil.description } }
    end

    assert_redirected_to admin_type_etat_civil_url(Admin::TypeEtatCivil.last)
  end

  test "should show admin_type_etat_civil" do
    get admin_type_etat_civil_url(@admin_type_etat_civil)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_etat_civil_url(@admin_type_etat_civil)
    assert_response :success
  end

  test "should update admin_type_etat_civil" do
    patch admin_type_etat_civil_url(@admin_type_etat_civil), params: { admin_type_etat_civil: { code: @admin_type_etat_civil.code, description: @admin_type_etat_civil.description } }
    assert_redirected_to admin_type_etat_civil_url(@admin_type_etat_civil)
  end

  test "should destroy admin_type_etat_civil" do
    assert_difference('Admin::TypeEtatCivil.count', -1) do
      delete admin_type_etat_civil_url(@admin_type_etat_civil)
    end

    assert_redirected_to admin_type_etat_civils_url
  end
end
