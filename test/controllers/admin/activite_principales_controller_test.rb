require 'test_helper'

class Admin::ActivitePrincipalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_activite_principale = admin_activite_principales(:one)
  end

  test "should get index" do
    get admin_activite_principales_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_activite_principale_url
    assert_response :success
  end

  test "should create admin_activite_principale" do
    assert_difference('Admin::ActivitePrincipale.count') do
      post admin_activite_principales_url, params: { admin_activite_principale: { description: @admin_activite_principale.description, secteur_activite_id: @admin_activite_principale.secteur_activite_id } }
    end

    assert_redirected_to admin_activite_principale_url(Admin::ActivitePrincipale.last)
  end

  test "should show admin_activite_principale" do
    get admin_activite_principale_url(@admin_activite_principale)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_activite_principale_url(@admin_activite_principale)
    assert_response :success
  end

  test "should update admin_activite_principale" do
    patch admin_activite_principale_url(@admin_activite_principale), params: { admin_activite_principale: { description: @admin_activite_principale.description, secteur_activite_id: @admin_activite_principale.secteur_activite_id } }
    assert_redirected_to admin_activite_principale_url(@admin_activite_principale)
  end

  test "should destroy admin_activite_principale" do
    assert_difference('Admin::ActivitePrincipale.count', -1) do
      delete admin_activite_principale_url(@admin_activite_principale)
    end

    assert_redirected_to admin_activite_principales_url
  end
end
