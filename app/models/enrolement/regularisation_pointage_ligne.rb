class Enrolement::RegularisationPointageLigne < ApplicationRecord
  belongs_to :allocataire, optional: true
  belongs_to :supprime_par, class_name: 'User', foreign_key: 'supprime_par_id', optional: true
  belongs_to :regularisation_pointage, class_name: 'Enrolement::RegularisationPointage', foreign_key: 'enrolement_regularisation_pointage_id'

  def peut_supprimer?(user)
    regularisation_pointage.creation? and user.admin?
  end

  def supprimer!(user)
    return unless peut_supprimer?(user)
    ActiveRecord::Base.transaction do
      self.supprime_par = user
      self.supprime_le = DateTime.now
      self.supprime = true
      self.save!
    end
  end

  def generate_paiement_allocataire
    return if supprime?
    return if allocataire.nil?

    ActiveRecord::Base.transaction do
      allocataire.echeances_manquantes.each { |echeance|
        periode_debut = echeance.periode_debut

        if allocataire.retraite? or allocataire.orphelin? or allocataire.veuve?
          allocataire.set_date_sortie_majoration
          allocataire.recalculer_allocation(periode_debut)
        end

        op = OrdrePaiement.create(regularisation_pointage: regularisation_pointage,
                                  dossier: allocataire,
                                  numero_allocataire: allocataire.numero_allocataire,
                                  num_echeance: "#{echeance.try(:periode_debut).try(:strftime, '%m/%Y')}_#{enrolement_regularisation_pointage_id}")

        # cotisation association allocataire
        # unless allocataire.admin_association_allocataire.nil?
        #   ComptaTransaction.create(
        #     en_tete: false,
        #     ordre_paiement: op,
        #     dossier: allocataire,
        #     code_operation: 'I_RETASSRET',
        #     code_classe_evenement: 'ECHEANCE',
        #     code_agence_liquidation: 'I_SG',
        #     numero_allocataire: allocataire.numero_allocataire,
        #     nom: allocataire.nom,
        #     prenom: allocataire.prenom,
        #     adresse: allocataire.adresse_rue,
        #     mode_paiement: allocataire.mode_paiement,
        #     code_banque_allocataire: allocataire.compte_bancaire_code_banque,
        #     numero_compte_allocataire: allocataire.rib,
        #     bank_id: allocataire.bank_id,
        #     bank_branch_id: allocataire.bank_branch_id,
        #     date_debut_periode: nil,
        #     date_fin_periode: nil,
        #     montant: -100,
        #     code_devise: 'XOF',
        #     description: "Régularisation Cotisation association #{allocataire.admin_association_allocataire.name}",
        #     admin_agence: allocataire.admin_agence,
        #     nin_allocataire: allocataire.numero_identification_nationale,
        #     telephone_allocataire: allocataire.telephone,
        #     mail_allocataire: allocataire.email,
        #     can_send_to_compta: true,
        #     date_comptable: periode_debut,
        #     admin_region: allocataire.admin_region,
        #     zone: allocataire.zone,
        #     infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
        #     infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
        #     infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
        #     infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
        #   )
        # end

        # remboursement allocataire
        allocataire.pret_allocataire_lignes.a_rembourser.each { |pret|
          ComptaTransaction.create(
            en_tete: false,
            ordre_paiement: op,
            dossier: pret,
            code_operation: 'I_RAT',
            code_classe_evenement: 'ECHEANCE',
            code_agence_liquidation: 'I_SG',
            numero_allocataire: allocataire.numero_allocataire,
            nom: allocataire.nom,
            prenom: allocataire.prenom,
            adresse: allocataire.adresse_rue,
            mode_paiement: allocataire.mode_paiement,
            code_banque_allocataire: allocataire.compte_bancaire_code_banque,
            numero_compte_allocataire: allocataire.rib,
            bank_id: allocataire.bank_id,
            bank_branch_id: allocataire.bank_branch_id,
            date_debut_periode: nil,
            date_fin_periode: nil,
            montant: -pret.montant_retenue,
            code_devise: 'XOF',
            description: "Régularisation Remboursement prêt #{pret.pret_allocataire.try(:type_pret)}",
            admin_agence: allocataire.admin_agence,
            nin_allocataire: allocataire.numero_identification_nationale,
            telephone_allocataire: allocataire.telephone,
            mail_allocataire: allocataire.email,
            can_send_to_compta: true,
            date_comptable: periode_debut,
            admin_region: allocataire.admin_region,
            zone: allocataire.zone,
            infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
            infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
            infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
            infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
          )
        }

        # avis tiers
        allocataire.avis_tiers.validation_directeur.a_rembourser.each { |at|
          ComptaTransaction.create(
            en_tete: false,
            ordre_paiement: op,
            dossier: at,
            code_operation: 'I_OSP',
            code_classe_evenement: 'ECHEANCE',
            code_agence_liquidation: 'I_SG',
            numero_allocataire: allocataire.numero_allocataire,
            nom: allocataire.nom,
            prenom: allocataire.prenom,
            adresse: allocataire.adresse_rue,
            mode_paiement: allocataire.mode_paiement,
            code_banque_allocataire: allocataire.compte_bancaire_code_banque,
            numero_compte_allocataire: allocataire.rib,
            bank_id: allocataire.bank_id,
            bank_branch_id: allocataire.bank_branch_id,
            date_debut_periode: nil,
            date_fin_periode: nil,
            montant: -at.montant_retenue,
            code_devise: 'XOF',
            description: "Régularisation Avis tier #{at.try(:type_operation)}",
            admin_agence: allocataire.admin_agence,
            nin_allocataire: allocataire.numero_identification_nationale,
            telephone_allocataire: allocataire.telephone,
            mail_allocataire: allocataire.email,
            can_send_to_compta: true,
            date_comptable: periode_debut,
            admin_region: allocataire.admin_region,
            zone: allocataire.zone,
            infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
            infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
            infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
            infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
          )
        }

        # pension alimentaire
        Allocataire.pension_alimentaire.versement_mensuels.actif.
          where(numero_allocataire_donneur: [allocataire.numero_allocataire, allocataire.ipres_ancien_matric].compact).each do |pa|
          ComptaTransaction.create(
            en_tete: false,
            ordre_paiement: op,
            dossier: allocataire,
            code_operation: 'I_RPA',
            code_classe_evenement: 'ECHEANCE',
            code_agence_liquidation: 'I_SG',
            numero_allocataire: allocataire.numero_allocataire,
            nom: allocataire.nom,
            prenom: allocataire.prenom,
            adresse: allocataire.adresse_rue,
            mode_paiement: allocataire.mode_paiement,
            code_banque_allocataire: allocataire.compte_bancaire_code_banque,
            numero_compte_allocataire: allocataire.rib,
            bank_id: allocataire.bank_id,
            bank_branch_id: allocataire.bank_branch_id,
            date_debut_periode: nil,
            date_fin_periode: nil,
            montant: -pa.montant_net,
            code_devise: 'XOF',
            description: "Régularisation Pension alimentaire pour #{pa.full_name} (#{pa.numero_allocataire})",
            admin_agence: allocataire.admin_agence,
            nin_allocataire: allocataire.numero_identification_nationale,
            telephone_allocataire: allocataire.telephone,
            mail_allocataire: allocataire.email,
            can_send_to_compta: true,
            date_comptable: periode_debut,
            admin_region: allocataire.admin_region,
            zone: allocataire.zone,
            infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
            infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
            infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
            infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
          )
        end

        # pret allocataire
        allocataire.pret_allocataire_lignes.non_verses.each { |pret|
          ComptaTransaction.create(
            en_tete: false,
            ordre_paiement: op,
            dossier: pret,
            code_operation: 'I_ATL',
            code_classe_evenement: 'ECHEANCE',
            code_agence_liquidation: 'I_SG',
            numero_allocataire: allocataire.numero_allocataire,
            nom: allocataire.nom,
            prenom: allocataire.prenom,
            adresse: allocataire.adresse_rue,
            mode_paiement: allocataire.mode_paiement,
            code_banque_allocataire: allocataire.compte_bancaire_code_banque,
            numero_compte_allocataire: allocataire.rib,
            bank_id: allocataire.bank_id,
            bank_branch_id: allocataire.bank_branch_id,
            date_debut_periode: nil,
            date_fin_periode: nil,
            montant: pret.montant,
            code_devise: 'XOF',
            description: "Régularisation Prêt #{pret.pret_allocataire.try(:type_pret)}",
            admin_agence: allocataire.admin_agence,
            nin_allocataire: allocataire.numero_identification_nationale,
            telephone_allocataire: allocataire.telephone,
            mail_allocataire: allocataire.email,
            can_send_to_compta: true,
            date_comptable: periode_debut,
            admin_region: allocataire.admin_region,
            zone: allocataire.zone,
            infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
            infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
            infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
            infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
          )
        }

        # pension mensuelle
        ComptaTransaction.create(
          ordre_paiement: op,
          dossier: allocataire,
          code_operation: 'I_EAC',
          code_classe_evenement: 'ECHEANCE',
          code_agence_liquidation: 'I_SG',
          numero_allocataire: allocataire.numero_allocataire,
          nom: allocataire.nom,
          prenom: allocataire.prenom,
          adresse: allocataire.adresse_rue,
          mode_paiement: allocataire.mode_paiement,
          code_banque_allocataire: allocataire.compte_bancaire_code_banque,
          numero_compte_allocataire: allocataire.rib,
          bank_id: allocataire.bank_id,
          bank_branch_id: allocataire.bank_branch_id,
          date_debut_periode: nil,
          date_fin_periode: nil,
          montant: allocataire.montant_net,
          montant_subvention: allocataire.montant_subvention,
          code_devise: 'XOF',
          description: "Régularisation Versement mensuel",
          admin_agence: allocataire.admin_agence,
          nin_allocataire: allocataire.numero_identification_nationale,
          telephone_allocataire: allocataire.telephone,
          mail_allocataire: allocataire.email,
          can_send_to_compta: true,
          date_comptable: periode_debut,
          admin_region: allocataire.admin_region,
          zone: allocataire.zone,

          infos_paiement_id_bhs: allocataire.infos_paiement_id_bhs,
          infos_paiement_id_ccp: allocataire.infos_paiement_id_ccp,
          infos_paiement_libelle_ccp: allocataire.infos_paiement_libelle_ccp,
          infos_paiement_succursale_cncas: allocataire.infos_paiement_succursale_cncas,
        )
      }

      allocataire.update_columns(etat: 1)
      self.update_columns(comptabilise: true)
    end
  end
end
