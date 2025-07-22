require "application_system_test_case"

class Admin::TypeRegimesTest < ApplicationSystemTestCase
  setup do
    @admin_type_regime = admin_type_regimes(:one)
  end

  test "visiting the index" do
    visit admin_type_regimes_url
    assert_selector "h1", text: "Admin/Type Regimes"
  end

  test "creating a Type regime" do
    visit admin_type_regimes_url
    click_on "New Admin/Type Regime"

    fill_in "Description", with: @admin_type_regime.description
    fill_in "Nom", with: @admin_type_regime.nom
    click_on "Create Type regime"

    assert_text "Type regime was successfully created"
    click_on "Back"
  end

  test "updating a Type regime" do
    visit admin_type_regimes_url
    click_on "Edit", match: :first

    fill_in "Description", with: @admin_type_regime.description
    fill_in "Nom", with: @admin_type_regime.nom
    click_on "Update Type regime"

    assert_text "Type regime was successfully updated"
    click_on "Back"
  end

  test "destroying a Type regime" do
    visit admin_type_regimes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Type regime was successfully destroyed"
  end
end
