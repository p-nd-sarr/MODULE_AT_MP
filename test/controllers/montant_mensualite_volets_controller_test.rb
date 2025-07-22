require 'test_helper'

class MontantMensualiteVoletsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @montant_mensualite_volet = montant_mensualite_volets(:one)
  end

  test "should get index" do
    get montant_mensualite_volets_url
    assert_response :success
  end

  test "should get new" do
    get new_montant_mensualite_volet_url
    assert_response :success
  end

  test "should create montant_mensualite_volet" do
    assert_difference('MontantMensualiteVolet.count') do
      post montant_mensualite_volets_url, params: { montant_mensualite_volet: { allocation_prenatale_id: @montant_mensualite_volet.allocation_prenatale_id, date_changement: @montant_mensualite_volet.date_changement, montant: @montant_mensualite_volet.montant, num_volet: @montant_mensualite_volet.num_volet } }
    end

    assert_redirected_to montant_mensualite_volet_url(MontantMensualiteVolet.last)
  end

  test "should show montant_mensualite_volet" do
    get montant_mensualite_volet_url(@montant_mensualite_volet)
    assert_response :success
  end

  test "should get edit" do
    get edit_montant_mensualite_volet_url(@montant_mensualite_volet)
    assert_response :success
  end

  test "should update montant_mensualite_volet" do
    patch montant_mensualite_volet_url(@montant_mensualite_volet), params: { montant_mensualite_volet: { allocation_prenatale_id: @montant_mensualite_volet.allocation_prenatale_id, date_changement: @montant_mensualite_volet.date_changement, montant: @montant_mensualite_volet.montant, num_volet: @montant_mensualite_volet.num_volet } }
    assert_redirected_to montant_mensualite_volet_url(@montant_mensualite_volet)
  end

  test "should destroy montant_mensualite_volet" do
    assert_difference('MontantMensualiteVolet.count', -1) do
      delete montant_mensualite_volet_url(@montant_mensualite_volet)
    end

    assert_redirected_to montant_mensualite_volets_url
  end
end
