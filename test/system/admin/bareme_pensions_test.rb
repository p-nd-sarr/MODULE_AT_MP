require "application_system_test_case"

class Admin::BaremePensionsTest < ApplicationSystemTestCase
  setup do
    @admin_bareme_pension = admin_bareme_pensions(:one)
  end

  test "visiting the index" do
    visit admin_bareme_pensions_url
    assert_selector "h1", text: "Admin/Bareme Pensions"
  end

  test "creating a Bareme pension" do
    visit admin_bareme_pensions_url
    click_on "New Admin/Bareme Pension"

    fill_in "Admin type regime", with: @admin_bareme_pension.admin_type_regime_id
    fill_in "Date debut validite", with: @admin_bareme_pension.date_debut_validite
    fill_in "Date fin validite", with: @admin_bareme_pension.date_fin_validite
    fill_in "Valeur point annuelle", with: @admin_bareme_pension.valeur_point_annuelle
    fill_in "Valeur point bimestrielle", with: @admin_bareme_pension.valeur_point_bimestrielle
    fill_in "Valeur point mensuelle", with: @admin_bareme_pension.valeur_point_mensuelle
    fill_in "Valeur point trimestrielle", with: @admin_bareme_pension.valeur_point_trimestrielle
    click_on "Create Bareme pension"

    assert_text "Bareme pension was successfully created"
    click_on "Back"
  end

  test "updating a Bareme pension" do
    visit admin_bareme_pensions_url
    click_on "Edit", match: :first

    fill_in "Admin type regime", with: @admin_bareme_pension.admin_type_regime_id
    fill_in "Date debut validite", with: @admin_bareme_pension.date_debut_validite
    fill_in "Date fin validite", with: @admin_bareme_pension.date_fin_validite
    fill_in "Valeur point annuelle", with: @admin_bareme_pension.valeur_point_annuelle
    fill_in "Valeur point bimestrielle", with: @admin_bareme_pension.valeur_point_bimestrielle
    fill_in "Valeur point mensuelle", with: @admin_bareme_pension.valeur_point_mensuelle
    fill_in "Valeur point trimestrielle", with: @admin_bareme_pension.valeur_point_trimestrielle
    click_on "Update Bareme pension"

    assert_text "Bareme pension was successfully updated"
    click_on "Back"
  end

  test "destroying a Bareme pension" do
    visit admin_bareme_pensions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Bareme pension was successfully destroyed"
  end
end
