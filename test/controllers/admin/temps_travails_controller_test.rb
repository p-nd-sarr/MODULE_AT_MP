require 'test_helper'

class Admin::TempsTravailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_temps_travail = admin_temps_travails(:one)
  end

  test "should get index" do
    get admin_temps_travails_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_temps_travail_url
    assert_response :success
  end

  test "should create admin_temps_travail" do
    assert_difference('Admin::TempsTravail.count') do
      post admin_temps_travails_url, params: { admin_temps_travail: { code: @admin_temps_travail.code, description: @admin_temps_travail.description } }
    end

    assert_redirected_to admin_temps_travail_url(Admin::TempsTravail.last)
  end

  test "should show admin_temps_travail" do
    get admin_temps_travail_url(@admin_temps_travail)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_temps_travail_url(@admin_temps_travail)
    assert_response :success
  end

  test "should update admin_temps_travail" do
    patch admin_temps_travail_url(@admin_temps_travail), params: { admin_temps_travail: { code: @admin_temps_travail.code, description: @admin_temps_travail.description } }
    assert_redirected_to admin_temps_travail_url(@admin_temps_travail)
  end

  test "should destroy admin_temps_travail" do
    assert_difference('Admin::TempsTravail.count', -1) do
      delete admin_temps_travail_url(@admin_temps_travail)
    end

    assert_redirected_to admin_temps_travails_url
  end
end
