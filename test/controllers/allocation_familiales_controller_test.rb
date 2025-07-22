require 'test_helper'

class AllocationFamilialesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @allocation_familiale = allocation_familiales(:one)
  end

  test "should get index" do
    get allocation_familiales_url
    assert_response :success
  end

  test "should get new" do
    get new_allocation_familiale_url
    assert_response :success
  end

  test "should create allocation_familiale" do
    assert_difference('AllocationFamiliale.count') do
      post allocation_familiales_url, params: { allocation_familiale: { ajoute_par_id: @allocation_familiale.ajoute_par_id, annee: @allocation_familiale.annee, date_soumission: @allocation_familiale.date_soumission, date_validation: @allocation_familiale.date_validation, dossier_prestation_id: @allocation_familiale.dossier_prestation_id, enfant_id: @allocation_familiale.enfant_id, etat: @allocation_familiale.etat, montant_paiement: @allocation_familiale.montant_paiement, motif_rejet: @allocation_familiale.motif_rejet, paiement: @allocation_familiale.paiement, traite_le: @allocation_familiale.traite_le, traite_par_id: @allocation_familiale.traite_par_id, trimestre: @allocation_familiale.trimestre, user_id: @allocation_familiale.user_id, valide_par_id: @allocation_familiale.valide_par_id } }
    end

    assert_redirected_to allocation_familiale_url(AllocationFamiliale.last)
  end

  test "should show allocation_familiale" do
    get allocation_familiale_url(@allocation_familiale)
    assert_response :success
  end

  test "should get edit" do
    get edit_allocation_familiale_url(@allocation_familiale)
    assert_response :success
  end

  test "should update allocation_familiale" do
    patch allocation_familiale_url(@allocation_familiale), params: { allocation_familiale: { ajoute_par_id: @allocation_familiale.ajoute_par_id, annee: @allocation_familiale.annee, date_soumission: @allocation_familiale.date_soumission, date_validation: @allocation_familiale.date_validation, dossier_prestation_id: @allocation_familiale.dossier_prestation_id, enfant_id: @allocation_familiale.enfant_id, etat: @allocation_familiale.etat, montant_paiement: @allocation_familiale.montant_paiement, motif_rejet: @allocation_familiale.motif_rejet, paiement: @allocation_familiale.paiement, traite_le: @allocation_familiale.traite_le, traite_par_id: @allocation_familiale.traite_par_id, trimestre: @allocation_familiale.trimestre, user_id: @allocation_familiale.user_id, valide_par_id: @allocation_familiale.valide_par_id } }
    assert_redirected_to allocation_familiale_url(@allocation_familiale)
  end

  test "should destroy allocation_familiale" do
    assert_difference('AllocationFamiliale.count', -1) do
      delete allocation_familiale_url(@allocation_familiale)
    end

    assert_redirected_to allocation_familiales_url
  end
end
