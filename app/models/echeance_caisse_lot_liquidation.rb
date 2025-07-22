class EcheanceCaisseLotLiquidation < ApplicationRecord
  belongs_to :echeance_caisse
  belongs_to :echeance_caisse_employeur
  belongs_to :liquide_par, class_name: 'User', foreign_key: :liquide_par_id, optional: true
  belongs_to :valide_ca_par, class_name: 'User', foreign_key: :valide_ca_par_id, optional: true
  belongs_to :valide_comptable_par, class_name: 'User', foreign_key: :valide_comptable_par_id, optional: true
  has_many :echeance_caisse_liquidations
  has_many :allocation_familiales, dependent: :destroy
  has_many :carriere_dossier_prestations, dependent: :destroy
  has_many :ordre_paiements

  validate :check_double_saving, on: :create

  def check_double_saving
    if EcheanceCaisseLotLiquidation.exists?(echeance_caisse_id: echeance_caisse_id, echeance_caisse_employeur_id: echeance_caisse_employeur_id, liquide: false)
      errors.add(:base, "Impossible d'initier deux liquidations à la fois.")
    end
  end

  def montant_total
    echeance_caisse_employeur.echeance_caisse_enfants.where(
      id: echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id)
    ).sum(:montant)
  end

  # @param [EcheanceCaisseDossier] dossier
  def nombre_enfants_pour_dossier(dossier)
    echeance_caisse_employeur.echeance_caisse_enfants.where(
      id: echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id),
      echeance_caisse_dossier: dossier
    ).pluck(:enfant_id).uniq.count
  end

  # @param [EcheanceCaisseDossier] dossier
  def montant_total_pour_dossier(dossier)
    echeance_caisse_employeur.echeance_caisse_enfants.where(
      id: echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id),
      echeance_caisse_dossier: dossier
    ).sum(:montant)
  end

  def generate_time_of_presence_and_allocations(user)
    self.echeance_caisse_liquidations.each { |liquidation|
      child_liquidations = EcheanceCaisseLiquidation.joins(echeance_caisse_enfant: :enfant).where(echeance_caisse_liquidations: { echeance_caisse_lot_liquidation_id: self.id }).where(enfants: { id: liquidation.echeance_caisse_enfant.enfant_id })
      amount = EcheanceCaisseEnfant.where(id: child_liquidations.pluck(:echeance_caisse_enfant_id)).sum(:montant)

      if not AllocationFamiliale.exists?(enfant_id: liquidation.echeance_caisse_enfant.enfant_id, trimestre: liquidation.echeance_caisse_enfant.echeance_caisse.trimestre, annee: liquidation.echeance_caisse_enfant.echeance_caisse.annee)
        AllocationFamiliale.create(
          enfant_id: liquidation.echeance_caisse_enfant.enfant_id,
          dossier_prestation_id: liquidation.echeance_caisse_enfant.dossier_prestation_id,
          trimestre: liquidation.echeance_caisse_enfant.echeance_caisse.trimestre,
          annee: liquidation.echeance_caisse_enfant.echeance_caisse.annee,
          date_ouverture_droit: Date.today,
          date_reception: Date.today,
          ajoute_par: user,
          etat: :soumis,
          date_liquidation: Date.today,
          date_soumission: Date.today,
          soumis_par: user,
          date_debut_validite: liquidation.echeance_caisse_enfant.echeance_caisse.periode_fin + 1.day,
          date_fin_validite: liquidation.echeance_caisse_enfant.echeance_caisse.periode_fin + 1.year,
          admin_agence: user.admin_agence,
          montant_paiement: amount,
          is_from_ech_paid: false,
          echeance_caisse_id: self.echeance_caisse.id,
          echeance_caisse_lot_liquidation_id: self.id
        )
      end

      unless liquidation.echeance_caisse_enfant.echeance_caisse_dossier.dossier_prestation.carriere_dossier_prestations.exists?(trimestre: echeance_caisse.trimestre, annee: echeance_caisse.annee)
        CarriereDossierPrestation.create(
          dossier_prestation_id: liquidation.echeance_caisse_enfant.dossier_prestation_id,
          date_depot: Date.today,
          date_document: Date.today,
          trimestre: echeance_caisse.trimestre,
          annee: echeance_caisse.annee,
          num_employeur: echeance_caisse_employeur.matric,
          raison_sociale: echeance_caisse_employeur.raison_sociale,
          premier_mois: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.temps_presence_mois1,
          deuxiem_mois: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.temps_presence_mois2,
          troisiem_mois: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.temps_presence_mois3,
          est_justifier: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.absence_justifie_mois1,
          raison_sociale_employeur_mois_2: echeance_caisse_employeur.raison_sociale,
          raison_sociale_employeur_mois_3: echeance_caisse_employeur.raison_sociale,
          num_employeur_mois_3: echeance_caisse_employeur.matric,
          num_employeur_mois_2: echeance_caisse_employeur.matric,
          est_justifier_mois2: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.absence_justifie_mois2,
          est_justifier_mois3: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.absence_justifie_mois3,
          motif_mois1: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.motif_absence_mois1,
          motif_mois2: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.motif_absence_mois2,
          motif_mois3: liquidation.echeance_caisse_enfant.echeance_caisse_dossier.motif_absence_mois3,
          infos_jour: true,
          echeance_caisse_id: echeance_caisse.id,
          echeance_caisse_lot_liquidation_id: self.id
        )
      end
    }
  end

  def generate_time_of_presence_for_dossiers_with_beneficiaries(user)
    echeance_caisse_employeur.echeance_caisse_dossiers.with_beneficiaries_added.each do |dossier|
      unless dossier.dossier_prestation.carriere_dossier_prestations.exists?(trimestre: echeance_caisse.trimestre, annee: echeance_caisse.annee)
        dossier.echeance_caisse_enfants.update_all(payable: false)
        CarriereDossierPrestation.create(
          dossier_prestation_id: dossier.dossier_prestation_id,
          date_depot: Date.today,
          date_document: Date.today,
          trimestre: echeance_caisse.trimestre,
          annee: echeance_caisse.annee,
          num_employeur: echeance_caisse_employeur.matric,
          raison_sociale: echeance_caisse_employeur.raison_sociale,
          premier_mois: dossier.temps_presence_mois1,
          deuxiem_mois: dossier.temps_presence_mois2,
          troisiem_mois: dossier.temps_presence_mois3,
          est_justifier: dossier.absence_justifie_mois1,
          raison_sociale_employeur_mois_2: echeance_caisse_employeur.raison_sociale,
          raison_sociale_employeur_mois_3: echeance_caisse_employeur.raison_sociale,
          num_employeur_mois_3: echeance_caisse_employeur.matric,
          num_employeur_mois_2: echeance_caisse_employeur.matric,
          est_justifier_mois2: dossier.absence_justifie_mois2,
          est_justifier_mois3: dossier.absence_justifie_mois3,
          motif_mois1: dossier.motif_absence_mois1,
          motif_mois2: dossier.motif_absence_mois2,
          motif_mois3: dossier.motif_absence_mois3,
          infos_jour: true,
          echeance_caisse_id: echeance_caisse.id,
          echeance_caisse_lot_liquidation_id: self.id
        )
      end
    end
  end

  def set_individual_payment
    # echeance_caisse_employeur.echeance_caisse_enfants.where(id: echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id)).update_all(paiement_individuel: true)
    echeance_caisse_employeur.echeance_caisse_dossiers.with_beneficiaries_added.each do |dossier|
      dossier.echeance_caisse_enfants.where(id: echeance_caisse_liquidations.pluck(:echeance_caisse_enfant_id), liquide: false).update_all(paiement_individuel: true)
    end
  end

  def valider_allocations_par_ca(user)
    allocation_familiales.where(is_from_ech_paid: false).each { |allocation|
      allocation.etat = :valide
      allocation.date_validation = Date.today
      allocation.valide_par = user
      allocation.traite_par = user
      puts 'errorrrrr', allocation.errors.full_messages unless allocation.save
    }
  end

  def valide_allocations_par_comptable(user)
    allocation_familiales.where(is_from_ech_paid: false).each { |allocation|
      allocation.traite_le = Date.today
      allocation.traite_par = user
      allocation.paiement = true
      allocation.save
    }
  end

  def delete_excess_liquidations
    # Find all liquidations for the current employer
    liquidations = echeance_caisse_liquidations

    # Group by each dossier and delete excess liquidations based on the limit
    liquidations.group_by { |liq| liq.echeance_caisse_enfant.echeance_caisse_dossier.id }.each do |dossier_id, liquidations_group|
      limit = EcheanceCaisseDossier.find(dossier_id).get_current_limit_of_children

      # Keep only the first `limit` liquidations and prepare to delete the others
      excess_liquidations = liquidations_group[limit..-1] || []

      # Delete the excess liquidations if any
      excess_liquidations.each(&:destroy!)
    end
  end
end
