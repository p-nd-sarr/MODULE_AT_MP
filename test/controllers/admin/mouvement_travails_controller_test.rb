require 'test_helper'

class Admin::MouvementTravailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_mouvement_travail = admin_mouvement_travails(:one)
  end

  test "should get index" do
    get admin_mouvement_travails_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_mouvement_travail_url
    assert_response :success
  end

  test "should create admin_mouvement_travail" do
    assert_difference('Admin::MouvementTravail.count') do
      post admin_mouvement_travails_url, params: { admin_mouvement_travail: { code: @admin_mouvement_travail.code, description: @admin_mouvement_travail.description } }
    end

    assert_redirected_to admin_mouvement_travail_url(Admin::MouvementTravail.last)
  end

  test "should show admin_mouvement_travail" do
    get admin_mouvement_travail_url(@admin_mouvement_travail)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_mouvement_travail_url(@admin_mouvement_travail)
    assert_response :success
  end

  test "should update admin_mouvement_travail" do
    patch admin_mouvement_travail_url(@admin_mouvement_travail), params: { admin_mouvement_travail: { code: @admin_mouvement_travail.code, description: @admin_mouvement_travail.description } }
    assert_redirected_to admin_mouvement_travail_url(@admin_mouvement_travail)
  end

  test "should destroy admin_mouvement_travail" do
    assert_difference('Admin::MouvementTravail.count', -1) do
      delete admin_mouvement_travail_url(@admin_mouvement_travail)
    end

    assert_redirected_to admin_mouvement_travails_url
  end
end
