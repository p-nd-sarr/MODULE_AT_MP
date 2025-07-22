require "application_system_test_case"

class Salarie::ConjointsTest < ApplicationSystemTestCase
  setup do
    @salarie_conjoint = salarie_conjoints(:one)
  end

  test "visiting the index" do
    visit salarie_conjoints_url
    assert_selector "h1", text: "Salarie/Conjoints"
  end

  test "creating a Conjoint" do
    visit salarie_conjoints_url
    click_on "New Salarie/Conjoint"

    fill_in "Date mariage", with: @salarie_conjoint.date_mariage
    fill_in "Date naissance", with: @salarie_conjoint.date_naissance
    fill_in "Nin", with: @salarie_conjoint.nin
    fill_in "Nom", with: @salarie_conjoint.nom
    fill_in "Prenom", with: @salarie_conjoint.prenom
    fill_in "User", with: @salarie_conjoint.user_id
    click_on "Create Conjoint"

    assert_text "Conjoint was successfully created"
    click_on "Back"
  end

  test "updating a Conjoint" do
    visit salarie_conjoints_url
    click_on "Edit", match: :first

    fill_in "Date mariage", with: @salarie_conjoint.date_mariage
    fill_in "Date naissance", with: @salarie_conjoint.date_naissance
    fill_in "Nin", with: @salarie_conjoint.nin
    fill_in "Nom", with: @salarie_conjoint.nom
    fill_in "Prenom", with: @salarie_conjoint.prenom
    fill_in "User", with: @salarie_conjoint.user_id
    click_on "Update Conjoint"

    assert_text "Conjoint was successfully updated"
    click_on "Back"
  end

  test "destroying a Conjoint" do
    visit salarie_conjoints_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Conjoint was successfully destroyed"
  end
end
