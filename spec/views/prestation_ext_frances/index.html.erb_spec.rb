require 'rails_helper'

RSpec.describe "prestation_ext_frances/index", type: :view do
  before(:each) do
    assign(:cfs_reversion_veuves, [
        CfsReversionVeuve.create!(
        sexe_salarie: 2,
        num_affiliation: "Num Affiliation",
        prenom: "Prenom",
        nom: "Nom",
        nom_jeune_fille: "Nom Jeune Fille",
        lieu_naissance: "Lieu Naissance",
        adresse_residence: "Adresse Residence",
        prenom_pere: "Prenom Pere",
        prenom_mere: "Prenom Mere",
        nom_pere: "Nom Pere",
        nom_mere: "Nom Mere",
        nationalite: 3,
        num_immatric_ipres: "Num Immatric Ipres",
        num_immatric_cfs: "Num Immatric Cfs",
        situation_familiale: 4,
        nature: 5,
        inapte: false,
        titulaire_pens_invalidite: false,
        titre_reg_gl: false,
        titre_reg_agric: false,
        titre_reg_minier: false,
        titre_reg_special: false,
        institution_reg_spec: "Institution Reg Spec",
        num_pension_inapt: "Num Pension Inapt",
        total_an_carr_sn: 6,
        total_an_carr_fr: 7,
        sens_convention: 8,
        decide_points: 9,
        decide_montant_annuel: 10,
        etat: 11,
        valide_par_id: 12,
        ajoute_par_id: 13,
        traite_par_id: 14,
        soumis_par_id: 15,
        etat_civil_demandeur_valid: false,
        grappe_fam_valid: false,
        activite_prof_valid: false,
        assur_residence_valid: false,
        assur_second_pays_valid: false,
        charge_second_pays_valid: false,
        document_valid: false,
        user: nil
      ),
        CfsReversionVeuve.create!(
        sexe_salarie: 2,
        num_affiliation: "Num Affiliation",
        prenom: "Prenom",
        nom: "Nom",
        nom_jeune_fille: "Nom Jeune Fille",
        lieu_naissance: "Lieu Naissance",
        adresse_residence: "Adresse Residence",
        prenom_pere: "Prenom Pere",
        prenom_mere: "Prenom Mere",
        nom_pere: "Nom Pere",
        nom_mere: "Nom Mere",
        nationalite: 3,
        num_immatric_ipres: "Num Immatric Ipres",
        num_immatric_cfs: "Num Immatric Cfs",
        situation_familiale: 4,
        nature: 5,
        inapte: false,
        titulaire_pens_invalidite: false,
        titre_reg_gl: false,
        titre_reg_agric: false,
        titre_reg_minier: false,
        titre_reg_special: false,
        institution_reg_spec: "Institution Reg Spec",
        num_pension_inapt: "Num Pension Inapt",
        total_an_carr_sn: 6,
        total_an_carr_fr: 7,
        sens_convention: 8,
        decide_points: 9,
        decide_montant_annuel: 10,
        etat: 11,
        valide_par_id: 12,
        ajoute_par_id: 13,
        traite_par_id: 14,
        soumis_par_id: 15,
        etat_civil_demandeur_valid: false,
        grappe_fam_valid: false,
        activite_prof_valid: false,
        assur_residence_valid: false,
        assur_second_pays_valid: false,
        charge_second_pays_valid: false,
        document_valid: false,
        user: nil
      )
    ])
  end

  it "renders a list of prestation_ext_frances" do
    render
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: "Num Affiliation".to_s, count: 2
    assert_select "tr>td", text: "Prenom".to_s, count: 2
    assert_select "tr>td", text: "Nom".to_s, count: 2
    assert_select "tr>td", text: "Nom Jeune Fille".to_s, count: 2
    assert_select "tr>td", text: "Lieu Naissance".to_s, count: 2
    assert_select "tr>td", text: "Adresse Residence".to_s, count: 2
    assert_select "tr>td", text: "Prenom Pere".to_s, count: 2
    assert_select "tr>td", text: "Prenom Mere".to_s, count: 2
    assert_select "tr>td", text: "Nom Pere".to_s, count: 2
    assert_select "tr>td", text: "Nom Mere".to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
    assert_select "tr>td", text: "Num Immatric Ipres".to_s, count: 2
    assert_select "tr>td", text: "Num Immatric Cfs".to_s, count: 2
    assert_select "tr>td", text: 4.to_s, count: 2
    assert_select "tr>td", text: 5.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: "Institution Reg Spec".to_s, count: 2
    assert_select "tr>td", text: "Num Pension Inapt".to_s, count: 2
    assert_select "tr>td", text: 6.to_s, count: 2
    assert_select "tr>td", text: 7.to_s, count: 2
    assert_select "tr>td", text: 8.to_s, count: 2
    assert_select "tr>td", text: 9.to_s, count: 2
    assert_select "tr>td", text: 10.to_s, count: 2
    assert_select "tr>td", text: 11.to_s, count: 2
    assert_select "tr>td", text: 12.to_s, count: 2
    assert_select "tr>td", text: 13.to_s, count: 2
    assert_select "tr>td", text: 14.to_s, count: 2
    assert_select "tr>td", text: 15.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
    assert_select "tr>td", text: nil.to_s, count: 2
  end
end
