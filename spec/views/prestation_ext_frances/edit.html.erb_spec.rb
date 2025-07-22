require 'rails_helper'

RSpec.describe "prestation_ext_frances/edit", type: :view do
  before(:each) do
    @prestation_ext_france = assign(:prestation_ext_france, CfsReversionVeuve.create!(
      sexe_salarie: 1,
      num_affiliation: "MyString",
      prenom: "MyString",
      nom: "MyString",
      nom_jeune_fille: "MyString",
      lieu_naissance: "MyString",
      adresse_residence: "MyString",
      prenom_pere: "MyString",
      prenom_mere: "MyString",
      nom_pere: "MyString",
      nom_mere: "MyString",
      nationalite: 1,
      num_immatric_ipres: "MyString",
      num_immatric_cfs: "MyString",
      situation_familiale: 1,
      nature: 1,
      inapte: false,
      titulaire_pens_invalidite: false,
      titre_reg_gl: false,
      titre_reg_agric: false,
      titre_reg_minier: false,
      titre_reg_special: false,
      institution_reg_spec: "MyString",
      num_pension_inapt: "MyString",
      total_an_carr_sn: 1,
      total_an_carr_fr: 1,
      sens_convention: 1,
      decide_points: 1,
      decide_montant_annuel: 1,
      etat: 1,
      valide_par_id: 1,
      ajoute_par_id: 1,
      traite_par_id: 1,
      soumis_par_id: 1,
      etat_civil_demandeur_valid: false,
      grappe_fam_valid: false,
      activite_prof_valid: false,
      assur_residence_valid: false,
      assur_second_pays_valid: false,
      charge_second_pays_valid: false,
      document_valid: false,
      user: nil
    ))
  end

  it "renders the edit prestation_ext_france form" do
    render

    assert_select "form[action=?][method=?]", prestation_ext_france_path(@prestation_ext_france), "post" do

      assert_select "input[name=?]", "prestation_ext_france[sexe_salarie]"

      assert_select "input[name=?]", "prestation_ext_france[num_affiliation]"

      assert_select "input[name=?]", "prestation_ext_france[prenom]"

      assert_select "input[name=?]", "prestation_ext_france[nom]"

      assert_select "input[name=?]", "prestation_ext_france[nom_jeune_fille]"

      assert_select "input[name=?]", "prestation_ext_france[lieu_naissance]"

      assert_select "input[name=?]", "prestation_ext_france[adresse_residence]"

      assert_select "input[name=?]", "prestation_ext_france[prenom_pere]"

      assert_select "input[name=?]", "prestation_ext_france[prenom_mere]"

      assert_select "input[name=?]", "prestation_ext_france[nom_pere]"

      assert_select "input[name=?]", "prestation_ext_france[nom_mere]"

      assert_select "input[name=?]", "prestation_ext_france[nationalite]"

      assert_select "input[name=?]", "prestation_ext_france[num_immatric_ipres]"

      assert_select "input[name=?]", "prestation_ext_france[num_immatric_cfs]"

      assert_select "input[name=?]", "prestation_ext_france[situation_familiale]"

      assert_select "input[name=?]", "prestation_ext_france[nature]"

      assert_select "input[name=?]", "prestation_ext_france[inapte]"

      assert_select "input[name=?]", "prestation_ext_france[titulaire_pens_invalidite]"

      assert_select "input[name=?]", "prestation_ext_france[titre_reg_gl]"

      assert_select "input[name=?]", "prestation_ext_france[titre_reg_agric]"

      assert_select "input[name=?]", "prestation_ext_france[titre_reg_minier]"

      assert_select "input[name=?]", "prestation_ext_france[titre_reg_special]"

      assert_select "input[name=?]", "prestation_ext_france[institution_reg_spec]"

      assert_select "input[name=?]", "prestation_ext_france[num_pension_inapt]"

      assert_select "input[name=?]", "prestation_ext_france[total_an_carr_sn]"

      assert_select "input[name=?]", "prestation_ext_france[total_an_carr_fr]"

      assert_select "input[name=?]", "prestation_ext_france[sens_convention]"

      assert_select "input[name=?]", "prestation_ext_france[decide_points]"

      assert_select "input[name=?]", "prestation_ext_france[decide_montant_annuel]"

      assert_select "input[name=?]", "prestation_ext_france[etat]"

      assert_select "input[name=?]", "prestation_ext_france[valide_par_id]"

      assert_select "input[name=?]", "prestation_ext_france[ajoute_par_id]"

      assert_select "input[name=?]", "prestation_ext_france[traite_par_id]"

      assert_select "input[name=?]", "prestation_ext_france[soumis_par_id]"

      assert_select "input[name=?]", "prestation_ext_france[etat_civil_demandeur_valid]"

      assert_select "input[name=?]", "prestation_ext_france[grappe_fam_valid]"

      assert_select "input[name=?]", "prestation_ext_france[activite_prof_valid]"

      assert_select "input[name=?]", "prestation_ext_france[assur_residence_valid]"

      assert_select "input[name=?]", "prestation_ext_france[assur_second_pays_valid]"

      assert_select "input[name=?]", "prestation_ext_france[charge_second_pays_valid]"

      assert_select "input[name=?]", "prestation_ext_france[document_valid]"

      assert_select "input[name=?]", "prestation_ext_france[user_id]"
    end
  end
end
