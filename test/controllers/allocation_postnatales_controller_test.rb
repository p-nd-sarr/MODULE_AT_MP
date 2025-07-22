require 'test_helper'

class AllocationPostnatalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @allocation_postnatale = allocation_postnatales(:one)
  end

  test "should get index" do
    get allocation_postnatales_url
    assert_response :success
  end

  test "should get new" do
    get new_allocation_postnatale_url
    assert_response :success
  end

  test "should create allocation_postnatale" do
    assert_difference('AllocationPostnatale.count') do
      post allocation_postnatales_url, params: { allocation_postnatale: { ajoute_par_id: @allocation_postnatale.ajoute_par_id, commentaire: @allocation_postnatale.commentaire, date_accouchement: @allocation_postnatale.date_accouchement, date_soumission: @allocation_postnatale.date_soumission, date_validation: @allocation_postnatale.date_validation, dossier_prestation_id: @allocation_postnatale.dossier_prestation_id, etat: @allocation_postnatale.etat, montant_paiement: @allocation_postnatale.montant_paiement, motif_rejet: @allocation_postnatale.motif_rejet, paiement: @allocation_postnatale.paiement, traite_le: @allocation_postnatale.traite_le, traite_par_id: @allocation_postnatale.traite_par_id, user: @allocation_postnatale.user, valide_par_id: @allocation_postnatale.valide_par_id, volet: @allocation_postnatale.volet } }
    end

    assert_redirected_to allocation_postnatale_url(AllocationPostnatale.last)
  end

  test "should show allocation_postnatale" do
    get allocation_postnatale_url(@allocation_postnatale)
    assert_response :success
  end

  test "should get edit" do
    get edit_allocation_postnatale_url(@allocation_postnatale)
    assert_response :success
  end

  test "should update allocation_postnatale" do
    patch allocation_postnatale_url(@allocation_postnatale), params: { allocation_postnatale: { ajoute_par_id: @allocation_postnatale.ajoute_par_id, commentaire: @allocation_postnatale.commentaire, date_accouchement: @allocation_postnatale.date_accouchement, date_soumission: @allocation_postnatale.date_soumission, date_validation: @allocation_postnatale.date_validation, dossier_prestation_id: @allocation_postnatale.dossier_prestation_id, etat: @allocation_postnatale.etat, montant_paiement: @allocation_postnatale.montant_paiement, motif_rejet: @allocation_postnatale.motif_rejet, paiement: @allocation_postnatale.paiement, traite_le: @allocation_postnatale.traite_le, traite_par_id: @allocation_postnatale.traite_par_id, user: @allocation_postnatale.user, valide_par_id: @allocation_postnatale.valide_par_id, volet: @allocation_postnatale.volet } }
    assert_redirected_to allocation_postnatale_url(@allocation_postnatale)
  end

  test "should destroy allocation_postnatale" do
    assert_difference('AllocationPostnatale.count', -1) do
      delete allocation_postnatale_url(@allocation_postnatale)
    end

    assert_redirected_to allocation_postnatales_url
  end
end
