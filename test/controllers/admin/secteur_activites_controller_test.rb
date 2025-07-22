require 'test_helper'

class Admin::SecteurActivitesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_secteur_activite = admin_secteur_activites(:one)
  end

  test "should get index" do
    get admin_secteur_activites_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_secteur_activite_url
    assert_response :success
  end

  test "should create admin_secteur_activite" do
    assert_difference('Admin::SecteurActivite.count') do
      post admin_secteur_activites_url, params: { admin_secteur_activite: { description: @admin_secteur_activite.description } }
    end

    assert_redirected_to admin_secteur_activite_url(Admin::SecteurActivite.last)
  end

  test "should show admin_secteur_activite" do
    get admin_secteur_activite_url(@admin_secteur_activite)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_secteur_activite_url(@admin_secteur_activite)
    assert_response :success
  end

  test "should update admin_secteur_activite" do
    patch admin_secteur_activite_url(@admin_secteur_activite), params: { admin_secteur_activite: { description: @admin_secteur_activite.description } }
    assert_redirected_to admin_secteur_activite_url(@admin_secteur_activite)
  end

  test "should destroy admin_secteur_activite" do
    assert_difference('Admin::SecteurActivite.count', -1) do
      delete admin_secteur_activite_url(@admin_secteur_activite)
    end

    assert_redirected_to admin_secteur_activites_url
  end
end
