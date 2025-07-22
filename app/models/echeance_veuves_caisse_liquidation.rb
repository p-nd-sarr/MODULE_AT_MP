class EcheanceVeuvesCaisseLiquidation < ApplicationRecord

  belongs_to :echeance_veuves_caisse_enfant
  belongs_to :compta_transaction
  belongs_to :echeance_veuves_caisse_lot_liquidation

  # @param [User] user
  # @param [OrdrePaiement] op
  # @param [Conjoint] conjoint
  # def liquider(user, op, conjoint)
  #   ActiveRecord::Base.transaction do
  #     ech_liquidations = EcheanceVeuvesCaisseLiquidation.where(echeance_veuves_caisse_enfant_id: self.echeance_veuves_caisse_enfant.enfant.echeance_veuves_caisse_enfants.select(:id))
  #     montant_total = EcheanceVeuvesCaisseEnfant.where(id: ech_liquidations.select(:echeance_veuves_caisse_enfant_id), echeance_veuves_caisse_id: echeance_veuves_caisse_enfant.echeance_veuves_caisse.id).sum(:montant)
  #     self.echeance_veuves_caisse_enfant.liquide = true
  #     self.echeance_veuves_caisse_enfant.save
  #
  #     allocation = AllocationFamiliale.create(
  #       enfant_id: echeance_veuves_caisse_enfant.enfant_id,
  #       ordre_paiement_id: op.id,
  #       dossier_prestation_id: echeance_veuves_caisse_enfant.dossier_prestation_id,
  #       trimestre: echeance_veuves_caisse_enfant.echeance_veuves_caisse.trimestre,
  #       annee: echeance_veuves_caisse_enfant.echeance_veuves_caisse.annee,
  #       date_ouverture_droit: Date.today,
  #       date_reception: Date.today,
  #       ajoute_par: user,
  #       etat: :valide,
  #       date_liquidation: self.echeance_veuves_caisse_lot_liquidation.date_liquidation,
  #       soumis_par: self.echeance_veuves_caisse_lot_liquidation.liquide_par,
  #       date_validation: self.echeance_veuves_caisse_lot_liquidation.date_validation_ca,
  #       valide_par: self.echeance_veuves_caisse_lot_liquidation.valide_ca_par,
  #       traite_par: user,
  #       traite_le: Date.today,
  #       paiement: true,
  #       date_debut_validite: echeance_veuves_caisse_enfant.echeance_veuves_caisse.periode_fin + 1.day,
  #       date_fin_validite: echeance_veuves_caisse_enfant.echeance_veuves_caisse.periode_fin + 1.year,
  #       admin_agence: user.admin_agence,
  #       montant_paiement: montant_total,
  #       echeance_veuves_caisse_id: self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.id,
  #       echeance_veuves_caisse_lot_liquidation_id: self.echeance_veuves_caisse_lot_liquidation.id
  #     )
  #     if ComptaTransaction.exists?(dossier: allocation, statut: [:paye, :en_cours])
  #       compta_transaction = ComptaTransaction.find_by(dossier: allocation, statut: [:paye, :en_cours])
  #     else
  #       compta_transaction = ComptaTransaction.create(
  #         ordre_paiement: op,
  #         dossier: allocation,
  #         code_operation: 'PF_AF',
  #         code_classe_evenement: 'ECHEANCE',
  #         code_agence_liquidation: user.admin_agence.code_psrm,
  #         numero_allocataire: conjoint.numero_piece,
  #         id_reel_allocataire: conjoint.numero_piece,
  #         nom: conjoint.nom,
  #         prenom: conjoint.prenom,
  #         mode_paiement: :caisse_css,
  #         date_debut_periode: self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.periode_debut,
  #         date_fin_periode: self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.periode_fin,
  #         montant: montant_total,
  #         code_devise: 'XOF',
  #         description: "Echeance CSS Veuves : #{self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.annee}#{self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.trimestre}",
  #         admin_agence: user.admin_agence,
  #         date_comptable: Date.today
  #       )
  #     end
  #
  #     self.compta_transaction = compta_transaction
  #     self.liquide = true
  #     self.save
  #
  #
  #     # @TODO : création de la carrière dossier prestation
  #     # CarriereDossierPrestation.create(
  #     #
  #     # )
  #   end
  # end

  def liquider(user, op, conjoint)
    ActiveRecord::Base.transaction do
      # Liquidation and montant_total calculation
      ech_liquidations = find_liquidations
      montant_total = calculate_total_montant(ech_liquidations)

      # Mark echeance as liquidated
      mark_as_liquidated

      # Create Allocation Familiale
      allocation = create_allocation_familiale(user, op, conjoint, montant_total)

      # Create or find ComptaTransaction
      compta_transaction = create_or_find_compta_transaction(user, op, conjoint, montant_total, allocation)

      # Assign the transaction to the current liquidation and save
      finalize_liquidation(compta_transaction)

    rescue => e
      # Handle any errors gracefully
      Rails.logger.error("Liquidation Error: #{e.message}")
      raise ActiveRecord::Rollback, "Transaction rolled back due to error"
    end
  end

  private

  def find_liquidations
    EcheanceVeuvesCaisseLiquidation.where(
      echeance_veuves_caisse_enfant_id: self.echeance_veuves_caisse_enfant.enfant.echeance_veuves_caisse_enfants.select(:id)
    )
  end

  def calculate_total_montant(ech_liquidations)
    EcheanceVeuvesCaisseEnfant
      .where(id: ech_liquidations.select(:echeance_veuves_caisse_enfant_id), echeance_veuves_caisse_id: echeance_veuves_caisse_enfant.echeance_veuves_caisse.id)
      .sum(:montant)
  end

  def mark_as_liquidated
    self.echeance_veuves_caisse_enfant.liquide = true
    self.echeance_veuves_caisse_enfant.save!
  end

  def create_allocation_familiale(user, op, conjoint, montant_total)
    return if AllocationFamiliale.where(enfant_id: echeance_veuves_caisse_enfant.enfant_id, trimestre: echeance_veuves_caisse_enfant.echeance_veuves_caisse.trimestre, annee: echeance_veuves_caisse_enfant.echeance_veuves_caisse.annee).exists?
    AllocationFamiliale.create!(
      enfant_id: echeance_veuves_caisse_enfant.enfant_id,
      ordre_paiement_id: op.id,
      dossier_prestation_id: echeance_veuves_caisse_enfant.dossier_prestation_id,
      trimestre: echeance_veuves_caisse_enfant.echeance_veuves_caisse.trimestre,
      annee: echeance_veuves_caisse_enfant.echeance_veuves_caisse.annee,
      date_ouverture_droit: Date.today,
      date_reception: Date.today,
      ajoute_par: user,
      etat: :valide,
      date_liquidation: self.echeance_veuves_caisse_lot_liquidation.date_liquidation,
      soumis_par: self.echeance_veuves_caisse_lot_liquidation.liquide_par,
      date_validation: self.echeance_veuves_caisse_lot_liquidation.date_validation_ca,
      valide_par: self.echeance_veuves_caisse_lot_liquidation.valide_ca_par,
      traite_par: user,
      traite_le: Date.today,
      paiement: true,
      date_debut_validite: echeance_veuves_caisse_enfant.echeance_veuves_caisse.periode_fin + 1.day,
      date_fin_validite: echeance_veuves_caisse_enfant.echeance_veuves_caisse.periode_fin + 1.year,
      admin_agence: user.admin_agence,
      montant_paiement: montant_total,
      echeance_veuves_caisse_id: self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.id,
      echeance_veuves_caisse_lot_liquidation_id: self.echeance_veuves_caisse_lot_liquidation.id
    )
  end

  def create_or_find_compta_transaction(user, op, conjoint, montant_total, allocation)
    return if allocation.nil?
    ComptaTransaction.find_or_create_by!(
      dossier: allocation,
      statut: [:paye, :en_cours]
    ) do |transaction|
      transaction.assign_attributes(
        ordre_paiement: op,
        code_operation: 'PF_AF',
        code_classe_evenement: 'ECHEANCE',
        code_agence_liquidation: user.admin_agence.code_psrm,
        numero_allocataire: conjoint.numero_piece,
        id_reel_allocataire: conjoint.numero_piece,
        nom: conjoint.nom,
        prenom: conjoint.prenom,
        mode_paiement: :caisse_css,
        date_debut_periode: self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.periode_debut,
        date_fin_periode: self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.periode_fin,
        montant: montant_total,
        code_devise: 'XOF',
        description: "Echeance CSS Veuves : #{self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.annee}#{self.echeance_veuves_caisse_enfant.echeance_veuves_caisse.trimestre}",
        admin_agence: user.admin_agence,
        date_comptable: Date.today
      )
    end
  end

  def finalize_liquidation(compta_transaction)
    self.compta_transaction = compta_transaction
    self.liquide = true
    self.save!
  end

end
