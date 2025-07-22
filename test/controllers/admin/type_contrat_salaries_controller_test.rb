require 'test_helper'

class Admin::TypeContratSalariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_type_contrat_salarie = admin_type_contrat_salaries(:one)
  end

  test "should get index" do
    get admin_type_contrat_salaries_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_type_contrat_salarie_url
    assert_response :success
  end

  test "should create admin_type_contrat_salarie" do
    assert_difference('Admin::TypeContratSalarie.count') do
      post admin_type_contrat_salaries_url, params: { admin_type_contrat_salarie: { code: @admin_type_contrat_salarie.code, description: @admin_type_contrat_salarie.description } }
    end

    assert_redirected_to admin_type_contrat_salarie_url(Admin::TypeContratSalarie.last)
  end

  test "should show admin_type_contrat_salarie" do
    get admin_type_contrat_salarie_url(@admin_type_contrat_salarie)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_type_contrat_salarie_url(@admin_type_contrat_salarie)
    assert_response :success
  end

  test "should update admin_type_contrat_salarie" do
    patch admin_type_contrat_salarie_url(@admin_type_contrat_salarie), params: { admin_type_contrat_salarie: { code: @admin_type_contrat_salarie.code, description: @admin_type_contrat_salarie.description } }
    assert_redirected_to admin_type_contrat_salarie_url(@admin_type_contrat_salarie)
  end

  test "should destroy admin_type_contrat_salarie" do
    assert_difference('Admin::TypeContratSalarie.count', -1) do
      delete admin_type_contrat_salarie_url(@admin_type_contrat_salarie)
    end

    assert_redirected_to admin_type_contrat_salaries_url
  end
end
