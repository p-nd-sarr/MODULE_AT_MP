require "application_system_test_case"

class Admin::BaremesTest < ApplicationSystemTestCase
  setup do
    @admin_bareme = admin_baremes(:one)
  end

  test "visiting the index" do
    visit admin_baremes_url
    assert_selector "h1", text: "Admin/Baremes"
  end

  test "creating a Bareme" do
    visit admin_baremes_url
    click_on "New Admin/Bareme"

    fill_in "Admin type regime", with: @admin_bareme.admin_type_regime_id
    fill_in "Date debut validite", with: @admin_bareme.date_debut_validite
    fill_in "Date fin validite", with: @admin_bareme.date_fin_validite
    fill_in "Periode", with: @admin_bareme.periode
    fill_in "Plafond salaire", with: @admin_bareme.plafond_salaire
    fill_in "Taux", with: @admin_bareme.taux
    fill_in "Valeur point", with: @admin_bareme.valeur_point
    click_on "Create Bareme"

    assert_text "Bareme was successfully created"
    click_on "Back"
  end

  test "updating a Bareme" do
    visit admin_baremes_url
    click_on "Edit", match: :first

    fill_in "Admin type regime", with: @admin_bareme.admin_type_regime_id
    fill_in "Date debut validite", with: @admin_bareme.date_debut_validite
    fill_in "Date fin validite", with: @admin_bareme.date_fin_validite
    fill_in "Periode", with: @admin_bareme.periode
    fill_in "Plafond salaire", with: @admin_bareme.plafond_salaire
    fill_in "Taux", with: @admin_bareme.taux
    fill_in "Valeur point", with: @admin_bareme.valeur_point
    click_on "Update Bareme"

    assert_text "Bareme was successfully updated"
    click_on "Back"
  end

  test "destroying a Bareme" do
    visit admin_baremes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Bareme was successfully destroyed"
  end
end
