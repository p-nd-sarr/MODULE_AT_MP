require "application_system_test_case"

class Admin::MouvementTravailFinsTest < ApplicationSystemTestCase
  setup do
    @admin_mouvement_travail_fin = admin_mouvement_travail_fins(:one)
  end

  test "visiting the index" do
    visit admin_mouvement_travail_fins_url
    assert_selector "h1", text: "Admin/Mouvement Travail Fins"
  end

  test "creating a Mouvement travail fin" do
    visit admin_mouvement_travail_fins_url
    click_on "New Admin/Mouvement Travail Fin"

    fill_in "Code", with: @admin_mouvement_travail_fin.code
    fill_in "Description", with: @admin_mouvement_travail_fin.description
    click_on "Create Mouvement travail fin"

    assert_text "Mouvement travail fin was successfully created"
    click_on "Back"
  end

  test "updating a Mouvement travail fin" do
    visit admin_mouvement_travail_fins_url
    click_on "Edit", match: :first

    fill_in "Code", with: @admin_mouvement_travail_fin.code
    fill_in "Description", with: @admin_mouvement_travail_fin.description
    click_on "Update Mouvement travail fin"

    assert_text "Mouvement travail fin was successfully updated"
    click_on "Back"
  end

  test "destroying a Mouvement travail fin" do
    visit admin_mouvement_travail_fins_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Mouvement travail fin was successfully destroyed"
  end
end
