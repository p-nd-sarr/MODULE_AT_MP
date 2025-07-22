class MaladieProfessionnelle < ApplicationRecord
  has_many :mp_documents, dependent: :destroy
  
  ETAT = {
      a_soumettre: 1,
      en_instruction: 2,
      accepte: 3,
      rejete: 4,
      en_attente_information: 5
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
  }

  LIEU_ACCIDENT = {
    non_precise: 1,
    entre_domicile_et_bureau: 2,
    deplacement_pendant_hr_travail: 3,
    lieu_de_travail_de_entreprise: 4,
    travail_domicile: 5
  }
   
  SITUATION_MATRIMONIALE = {
    marie: 1,
    divorce: 2,
    celibataire: 3,
    veuf: 4
  }

  NATIONALITE_SALARIE = {
    senegalais: 1,
    etranger: 2
  }

  TYPE_DE_CONTRAT_TRAVAIL = {
    permanent: 1,
    journalier: 2,
    saisonier: 3,
    autres_cdd: 4
  }

  enum etat: ETAT
  enum situation_matrimoniale_salarie: SITUATION_MATRIMONIALE
  enum nationalite_salarie: NATIONALITE_SALARIE
  enum type_de_contrat_travail_salarie: TYPE_DE_CONTRAT_TRAVAIL
  enum qualification_professionnelle_salarie: QUALIFICATION_PROFESSIONNELLE
  
end
