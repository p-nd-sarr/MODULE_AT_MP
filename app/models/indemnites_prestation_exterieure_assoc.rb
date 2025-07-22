class IndemnitesPrestationExterieureAssoc < ApplicationRecord

  belongs_to :indemnites_prestation_exterieure
  belongs_to :caf_enfant
  belongs_to :ordre_paiement, optional: true

  after_save :generate_compta_transaction

  def generate_compta_transaction
    indemnity = indemnites_prestation_exterieure
    return if indemnity.est_repris?
    return if indemnity.montant.nil?
    return if ordre_paiement.nil?

    new_transaction_amount = indemnity.montant / indemnity.indemnites_prestation_exterieure_assocs.size
    if indemnity.droit_valide? and not ComptaTransaction.exists?(dossier: self, statut: [:paye, :en_cours])
      return if new_transaction_amount <= 0
      cp = ComptaTransaction.create(
        en_tete: true,
        dossier: self,
        ordre_paiement: ordre_paiement,
        code_operation: 'PF_CAF',
        code_classe_evenement: 'LIQUIDATION',
        code_agence_liquidation: indemnity.valide_cpt_par.agence.try(:code_psrm) || 'C_SG', # à définir
        numero_allocataire: indemnity.prestation_exterieure.numero_secu_social,
        nom: indemnity.prestation_exterieure.nom,
        prenom: indemnity.prestation_exterieure.prenom,
        adresse: indemnity.prestation_exterieure.adresse_pays_emploi,
        mode_paiement: :caisse_css,
        code_banque_allocataire: nil,
        numero_compte_allocataire: nil,
        date_debut_periode: nil,
        date_fin_periode: nil,
        montant: new_transaction_amount,
        code_devise: 'XOF',
        statut: :en_cours,
        description: "Indemnité prestation extérieure CAF, enfant : #{caf_enfant.try(:full_name)}",
      )
      puts "OrdrePaiement errors: #{cp.errors.full_messages}" unless cp.persisted?

      cp
    end
  end

end
