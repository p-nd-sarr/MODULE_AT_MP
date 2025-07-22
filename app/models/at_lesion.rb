class AtLesion < ApplicationRecord
  belongs_to :arret_travail, optional: true

  NATURE_LESION = {
    #non_precise: 1,
    fracture: 2,
    brulure: 3,
    gelure: 4,
    amputation: 5,
    plaie: 6,
    inflamation:7,
    contusion:8,
    entorse: 9,
    luxation: 10,
    asphyxie: 11,
    commotion: 12,
    corps_etranger: 13,
    fibrillation_coeur: 14,
    hernies: 15,
    lumbago: 16,
    paralyse: 17,
    noyade: 18,
    ecrasement_partie_corps: 19,
    poly_traumatisme: 20,
    cecite: 21,
    perte_partille_vision: 22,
    lombalgies_residuelles: 23,
    traumatismes: 24,
    dermatose_professionnelle: 25,
    raideur: 26,
    douleurs: 27,
    electrocution: 28,
    congestions: 29,
    hemoragie: 30,
    crush_syndrome: 31,
    tetanos: 32,
    surdite: 33,
    hepatite_virale: 34
  }.freeze

  SIEGEE_LESION = {
    #non_precise: 1,
    tete: 2,
    yeux: 3,
    membres_superieurs: 4,
    membres_inferieurs: 5,
    main: 6,
    tronc: 7,
    pieds: 8,
    localisations_multiples: 9,
    sieges_internes: 10,
    systeme_nerveux: 11,
    bras_droit: 12,
    bras_gauche: 13,
    maxillaire: 14,
    visceres: 15,
    oreille: 16,
    jambe_gauche: 17,
    jambe_droite: 18,
    main_gauche: 10,
    main_droite: 20,
    pied_droit: 21,
    pied_gauche: 22
  }.freeze

  enum nature_lesion: NATURE_LESION
  enum siege_lesion: SIEGEE_LESION,  _prefix: :lesion

  before_update :date_debut_valid?

  def date_debut_valid?
    puts "DATA: ", Date.today
    puts "DATA_Created:", created_at.to_date
    if created_at > Date.today
      errors.add(:created_at, "ne peut pas être postérieure à la date de debut")
    end
    if created_at > arret_travail.date_accident
      errors.add(:created_at, "ne peut pas être postérieure à la date de debut")
    end
  end
end
