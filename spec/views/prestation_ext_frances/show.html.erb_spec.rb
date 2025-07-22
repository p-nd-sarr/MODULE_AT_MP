require 'rails_helper'

RSpec.describe "prestation_ext_frances/show", type: :view do
  before(:each) do
    @prestation_ext_france = assign(:prestation_ext_france, CfsReversionVeuve.create!(
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
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Num Affiliation/)
    expect(rendered).to match(/Prenom/)
    expect(rendered).to match(/Nom/)
    expect(rendered).to match(/Nom Jeune Fille/)
    expect(rendered).to match(/Lieu Naissance/)
    expect(rendered).to match(/Adresse Residence/)
    expect(rendered).to match(/Prenom Pere/)
    expect(rendered).to match(/Prenom Mere/)
    expect(rendered).to match(/Nom Pere/)
    expect(rendered).to match(/Nom Mere/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Num Immatric Ipres/)
    expect(rendered).to match(/Num Immatric Cfs/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Institution Reg Spec/)
    expect(rendered).to match(/Num Pension Inapt/)
    expect(rendered).to match(/6/)
    expect(rendered).to match(/7/)
    expect(rendered).to match(/8/)
    expect(rendered).to match(/9/)
    expect(rendered).to match(/10/)
    expect(rendered).to match(/11/)
    expect(rendered).to match(/12/)
    expect(rendered).to match(/13/)
    expect(rendered).to match(/14/)
    expect(rendered).to match(/15/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(//)
  end
end
