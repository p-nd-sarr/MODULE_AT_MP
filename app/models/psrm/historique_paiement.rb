class Psrm::HistoriquePaiement < ApplicationRecord
  # self.table_name = 'cisadm.xxipres_histo_v2'
  self.table_name = 'psrm_histo_v2'
  self.primary_key = 'id'

  # Psrm::HistoriquePaiement.load_for_periode(2018, 1)

  attribute :fhnet, :integer
  attribute :fhmodp, :integer
  attribute :fhtypp, :integer
  attribute :id, :integer
  #attribute :exercice, :integer
  #attribute :trimestre, :integer

  def self.load_for_periode(annee, numero)
    OrdrePaiement.set_last_number(Date.new(annee, 1, 1).strftime('%Y%m%d'))

    paiements = Psrm::HistoriquePaiement.where(exercice: annee, trimestre: numero)

    p = paiements.first
    e = EcheancePaiement.find_or_create_by(est_repris: true,
                                           annee: annee,
                                           periode: p.periode,
                                           numero_periode: p.numero_periode,
                                           send_to_compta: true,
                                           periode_variation_debut: p.periode_variation_debut,
                                           periode_variation_fin: p.periode_variation_fin,
                                           workflow_state: 'valider_directeur')

    paiements = paiements.where.not(id: e.compta_transactions.map(&:id_reprise))

    nb = paiements.count
    i = 0
    paiements.each do |paiement|
      MyJob.perform_later(e.id, paiement) #unless ComptaTransaction.exists?(id_reprise: paiement.id)
      i += 1
      puts "#{(100.0 * i / nb).ceil(2)} %"
    end
    puts "OK"
  end

  def mensuelle?
    periode == :mensuelle
  end

  def bimestrielle?
    periode == :bimestrielle
  end

  def trimestrielle?
    periode == :trimestrielle
  end

  def annee
    exercice.to_i
  end

  def statut
    return :regularise unless fhtypp.zero?
    return :impaye unless (fhreje.strip == '0' or fhreje.strip.empty?)
    :paye
  end

  def numero_periode
    trimestre.to_i
  end

  def periode
    return :trimestrielle if (1958..2006).include?(annee)
    return :bimestrielle if (2007..2016).include?(annee)
    :mensuelle
  end

  def periode_debut
    return Date.new(annee, numero_periode, 1).beginning_of_month if mensuelle?
    return Date.new(annee, numero_periode * 2, 1).beginning_of_bimester if bimestrielle?
    return Date.new(annee, numero_periode * 3, 1).beginning_of_quarter if trimestrielle?
  end

  def periode_fin
    return Date.new(annee, numero_periode, 1).end_of_month if mensuelle?
    return Date.new(annee, numero_periode * 2, 1).end_of_bimester if bimestrielle?
    return Date.new(annee, numero_periode * 3, 1).end_of_quarter if trimestrielle?
  end

  def periode_variation_debut
    return periode_debut - 1.month if mensuelle?
    return periode_debut - 2.month if bimestrielle?
    return periode_debut - 3.month if trimestrielle?
  end

  def periode_variation_fin
    periode_debut - 1.day
  end

  def load(e_id)
    return if ComptaTransaction.exists?(id_reprise: id)

    #allocataire = Allocataire.find_by("numero_allocataire = ? or ipres_ancien_matric = ?", matricule.strip, matricule.strip)
    a = get_infos_allocataire

    op = OrdrePaiement.create(est_repris: true,
                              echeance_paiement_id: e_id,
                              dossier_id: a['id'],
                              dossier_type: 'Allocataire',
                              numero_allocataire: (a['numero_allocataire'] || matricule.strip),
                              statut: statut,
                              created_at: Date.new(annee, 1, 1))

    ComptaTransaction.create(
      est_repris: true,
      id_reprise: id,
      echeance_paiement_id: e_id,
      ordre_paiement: op,
      dossier_id: a['id'],
      dossier_type: 'Allocataire',
      code_operation: '',
      code_classe_evenement: '',
      code_agence_liquidation: '',
      numero_allocataire: (a['numero_allocataire'] || matricule.strip),
      nom: a['nom'],
      prenom: a['prenom'],
      adresse: a['adresse_rue'],
      mode_paiement: fhmodp.zero? ? 5 : fhmodp,
      code_banque_allocataire: nil,
      numero_compte_allocataire: nil,
      bank_id: nil,
      bank_branch_id: nil,
      date_debut_periode: nil,
      date_fin_periode: nil,
      montant: fhnet,
      code_devise: 'XOF',
      statut: statut,
      description: "Reprise",
      admin_agence: nil,
      nin_allocataire: a['numero_identification_nationale'],
      telephone_allocataire: a['telephone'],
      mail_allocataire: a['email'],
      can_send_to_compta: true,
      send_to_compta: true,
      date_comptable: periode_debut,
    )
    puts "OK"
  end

  def get_infos_allocataire
    key = "his_pay:allocataire:#{matricule.strip}"
    r = $redis.get(key)
    if r.nil?
      allocataire = Allocataire.find_by("numero_allocataire = ? or ipres_ancien_matric = ?", matricule.strip, matricule.strip)
      data = {
        'id' => allocataire.try(:id),
        'numero_allocataire' => allocataire.try(:numero_allocataire),
        'nom' => allocataire.try(:nom),
        'prenom' => allocataire.try(:prenom),
        'adresse_rue' => allocataire.try(:adresse_rue),
        'numero_identification_nationale' => allocataire.try(:numero_identification_nationale),
        'telephone' => allocataire.try(:telephone),
        'email' => allocataire.try(:email),
      }
      $redis.set(key, data.to_json)
      data
    else
      JSON.parse(r)
    end
  end
end
