require 'test_helper'

class Admin::MotifSortiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_motif_sortie = admin_motif_sorties(:one)
  end

  test "should get index" do
    get admin_motif_sorties_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_motif_sortie_url
    assert_response :success
  end

  test "should create admin_motif_sortie" do
    assert_difference('Admin::MotifSortie.count') do
      post admin_motif_sorties_url, params: { admin_motif_sortie: { code: @admin_motif_sortie.code, description: @admin_motif_sortie.description } }
    end

    assert_redirected_to admin_motif_sortie_url(Admin::MotifSortie.last)
  end

  test "should show admin_motif_sortie" do
    get admin_motif_sortie_url(@admin_motif_sortie)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_motif_sortie_url(@admin_motif_sortie)
    assert_response :success
  end

  test "should update admin_motif_sortie" do
    patch admin_motif_sortie_url(@admin_motif_sortie), params: { admin_motif_sortie: { code: @admin_motif_sortie.code, description: @admin_motif_sortie.description } }
    assert_redirected_to admin_motif_sortie_url(@admin_motif_sortie)
  end

  test "should destroy admin_motif_sortie" do
    assert_difference('Admin::MotifSortie.count', -1) do
      delete admin_motif_sortie_url(@admin_motif_sortie)
    end

    assert_redirected_to admin_motif_sorties_url
  end
end
