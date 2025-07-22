require 'rails_helper'

RSpec.describe "allocataire_cnavs/edit", type: :view do
  before(:each) do
    @allocataire_cnav = assign(:allocataire_cnav, AllocataireCnav.create!(
      dossier_cnav: nil,
      numero: "MyString",
      prenom: "MyString",
      nom: "MyString",
      admin_region_id: 1,
      montant: 1,
      origine: "MyString",
      compte: "MyString",
      caisse_bk: 1,
      valide_par_id: 1,
      user: nil,
      ajoute_par_id: 1,
      traite_par_id: 1,
      motif_rejet: "MyString",
      montant_paiement: 1,
      paiement: false,
      etat: 1,
      mode_paiement: 1,
      numero_liquidation: "MyString"
    ))
  end

  it "renders the edit allocataire_cnav form" do
    render

    assert_select "form[action=?][method=?]", allocataire_cnav_path(@allocataire_cnav), "post" do

      assert_select "input[name=?]", "allocataire_cnav[dossier_cnav_id]"

      assert_select "input[name=?]", "allocataire_cnav[numero]"

      assert_select "input[name=?]", "allocataire_cnav[prenom]"

      assert_select "input[name=?]", "allocataire_cnav[nom]"

      assert_select "input[name=?]", "allocataire_cnav[admin_region_id]"

      assert_select "input[name=?]", "allocataire_cnav[montant]"

      assert_select "input[name=?]", "allocataire_cnav[origine]"

      assert_select "input[name=?]", "allocataire_cnav[compte]"

      assert_select "input[name=?]", "allocataire_cnav[caisse_bk]"

      assert_select "input[name=?]", "allocataire_cnav[valide_par_id]"

      assert_select "input[name=?]", "allocataire_cnav[user_id]"

      assert_select "input[name=?]", "allocataire_cnav[ajoute_par_id]"

      assert_select "input[name=?]", "allocataire_cnav[traite_par_id]"

      assert_select "input[name=?]", "allocataire_cnav[motif_rejet]"

      assert_select "input[name=?]", "allocataire_cnav[montant_paiement]"

      assert_select "input[name=?]", "allocataire_cnav[paiement]"

      assert_select "input[name=?]", "allocataire_cnav[etat]"

      assert_select "input[name=?]", "allocataire_cnav[mode_paiement]"

      assert_select "input[name=?]", "allocataire_cnav[numero_liquidation]"
    end
  end
end
