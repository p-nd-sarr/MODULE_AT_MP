class ArretTravailGed < ApplicationRecord
  ETAT = {
    instruction: 1,
    accepte: 2,
    rejete: 3,
    gueris: 4,
    rechute: 5,
    decede: 6
  }.freeze

  CONSEQUENCE_ACCIDENT_TRAVAIL = {
    arret_travail: 1,
    deces: 2,
    sans_arret_travail: 3
  }.freeze

  INCAPACITE_PERMANENTE = {
    partielle: 1,
    totale: 2
  }.freeze

  SEXE = {
    homme: 1,
    femme: 2
  }.freeze

  TYPE_DE_PIECE = {
    cni: 1,
    carte_cedeao: 2,
    carte_consulaire: 3,
    passeport: 4,
    extrait_de_naissance: 5
  }.freeze

  QUALIFICATION_PROFESSIONNELLE = {
    cadre: 1,
    technicien: 2,
    agent_de_maitrise: 3,
    employes: 4,
    apprentis: 5,
    manoeuvres: 6,
    ouvriers_specialises: 7,
    ouvrier_qualifie: 8,
    divers: 9
  }.freeze

  LIEU_ACCIDENT = {
    lieu_travail: 1,
    deplacement_pendant_hr_travail: 2,
    entre_domicile_et_bureau: 3,
    deplacement_pendant_hr_pause: 4,
    en_mer: 5,
    voyage_et_mission: 6,
    non_precise: 7
  }.freeze

  AGENT_MATERIEL = {
    accident_de_plein_pied: 1,
    chute_dun_niveau: 2,
    objets_en_cours_de_manutention_manuelle: 3,
    objets_ou_masse_en_mouvement: 4,
    particules_ou_petits_elements_de_matieres: 5,
    appareils_de_levage_amarrage_prehension: 6,
    vehicule: 7,
    machine_productrice_transformation_energie: 8,
    organe_transmission: 9,
    machine_transmission: 10,
    machine_a_broyer_concasser_pulveriser_diviser: 11,
    machine_a_malaxer_melanger: 12,
    machine_a_cribler_tamiser_separer: 13,
    presses_mecaniques_pilons: 14,
    machine_a_presser_mouler_injecter: 15,
    machine_cylind_laminer_etirer_planer_imprimer_melanger: 16,
    machine_a_couper_trancher_derouler_defibrer: 17,
    scies: 18,
    machine_a_tourner_percer_aleser_fraiser_raboter: 19,
    machine_a_percer_tourner_tourpiller_raboter: 20,
    machine_a_meuler_poncer_polir: 21,
    materiel_et_machines_a_souder: 22,
    machine_a_riveter_coudre_agrafer_mettre_oeillets: 23,
    mach_a_remplir_condition_empaquer_emballer_clouer: 24,
    machine_a_effilocher_ouvrer_battre_carder: 25,
    mach_a_filature_de_tissage_de_cablerie_et_d_appret: 26,
    materiel_engins_de_terrassement_et_travaux_annexes: 27,
    machine_diverses: 28,
    outils_mecaniques_tenus_ou_guides_a_la_main: 29,
    outils_a_main: 30,
    appareil_a_pression: 31,
    appareil_usten_util_prod_caustique_corro_toxi: 32,
    appareillage_et_installation_frigorifique: 33,
    vapeur_gaz_et_poussiere_deletere: 34,
    matiere_explosive: 35,
    electricite: 36,
    mat_divers: 37
  }.freeze

  DECLARANT = {
    ayant_droit: 1,
    employeur: 2,
    salarie: 3
  }.freeze

  TYPE_DECLARATION = {
    accident_travail: 1,
    accident_trajet: 2
  }.freeze

  SITUATION_MATRIMONIALE = {
    marie: 1,
    divorce: 2,
    celibataire: 3,
    veuf: 4
  }.freeze

  NATIONALITE_SALARIE = {
    senegalais: 1,
    etranger: 2
  }.freeze

  TYPE_DE_CONTRAT_TRAVAIL = {
    permanent: 1,
    journalier: 2,
    saisonier: 3,
    autres_cdd: 4
  }.freeze

  NATURE_ACCIDENT = {
    nouveau_accident: 1,
  }.freeze

  STATUS_GED = {
    en_creation: "en_creation",
    en_cours: "en_cours",
    valide: "valide"
  }.freeze

  enum etat: ETAT
  enum situation_matrimoniale_salarie: SITUATION_MATRIMONIALE
  enum nationalite_salarie: NATIONALITE_SALARIE
  enum type_de_contrat_travail_salarie: TYPE_DE_CONTRAT_TRAVAIL
  enum qualification_professionnelle_salarie: QUALIFICATION_PROFESSIONNELLE
  enum agent_materiel: AGENT_MATERIEL
  enum nature_accident: NATURE_ACCIDENT
  enum sexe: SEXE
  enum type_de_piece: TYPE_DE_PIECE
  enum type_declaration: TYPE_DECLARATION
  enum consequence_accident_travail: CONSEQUENCE_ACCIDENT_TRAVAIL
  enum incapacite_permanente: INCAPACITE_PERMANENTE
  enum declarant: DECLARANT
  enum status_ged: STATUS_GED
  enum lieu_accident: LIEU_ACCIDENT
  
  belongs_to :admin_agence, optional: true, :class_name => 'Admin::Agence', foreign_key: :admin_agence_id

  validates :status_ged, inclusion: { in: STATUS_GED.values }, allow_nil: true

  def peut_traiter?(current_user)
    en_creation? &&
    ( current_user.agent_accueil_direction_at? ||  current_user.agent_accueil? )
  end
end