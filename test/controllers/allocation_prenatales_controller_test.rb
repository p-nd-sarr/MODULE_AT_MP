require 'test_helper'

class AllocationPrenatalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @allocation_prenatale = allocation_prenatales(:one)
  end

  test "should get index" do
    get allocation_prenatales_url
    assert_response :success
  end

  test "should get new" do
    get new_allocation_prenatale_url
    assert_response :success
  end

  test "should create allocation_prenatale" do
    assert_difference('AllocationPrenatale.count') do
      post allocation_prenatales_url, params: { allocation_prenatale: { commentaire: @allocation_prenatale.commentaire, date_soumission: @allocation_prenatale.date_soumission, date_validation: @allocation_prenatale.date_validation, debut_grossesse: @allocation_prenatale.debut_grossesse, dossier_prestation_id: @allocation_prenatale.dossier_prestation_id, user_id: @allocation_prenatale.user_id, valide_par_id: @allocation_prenatale.valide_par_id, volet: @allocation_prenatale.volet } }
    end

    assert_redirected_to allocation_prenatale_url(AllocationPrenatale.last)
  end

  test "should show allocation_prenatale" do
    get allocation_prenatale_url(@allocation_prenatale)
    assert_response :success
  end

  test "should get edit" do
    get edit_allocation_prenatale_url(@allocation_prenatale)
    assert_response :success
  end

  test "should update allocation_prenatale" do
    patch allocation_prenatale_url(@allocation_prenatale), params: { allocation_prenatale: { commentaire: @allocation_prenatale.commentaire, date_soumission: @allocation_prenatale.date_soumission, date_validation: @allocation_prenatale.date_validation, debut_grossesse: @allocation_prenatale.debut_grossesse, dossier_prestation_id: @allocation_prenatale.dossier_prestation_id, user_id: @allocation_prenatale.user_id, valide_par_id: @allocation_prenatale.valide_par_id, volet: @allocation_prenatale.volet } }
    assert_redirected_to allocation_prenatale_url(@allocation_prenatale)
  end

  test "should destroy allocation_prenatale" do
    assert_difference('AllocationPrenatale.count', -1) do
      delete allocation_prenatale_url(@allocation_prenatale)
    end

    assert_redirected_to allocation_prenatales_url
  end
end
