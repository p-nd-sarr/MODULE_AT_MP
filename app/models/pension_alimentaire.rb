class PensionAlimentaire < ApplicationRecord
  ETAT = {
      creation: 1,
      validation_chef_service: 2,
      validation_directeur: 3,
      rejeter: 4,
  }.freeze

  enum etat: ETAT

  belongs_to :allocataire,
             foreign_key: :numero_allocataire,
             primary_key: :numero_allocataire
  belongs_to :ajouter_par, class_name: 'User', foreign_key: :ajouter_par_id, optional: true
  belongs_to :valider_par, class_name: 'User', foreign_key: :valider_par_id, optional: true
  belongs_to :affecter_allocataire, class_name: 'User', foreign_key: :gest_allocataire_id, optional: true

  scope :periode, ->(date_debut, date_fin) { where("valider_le > ? AND valider_le < ?", date_debut, date_fin) }

  before_create :create_numero_dossier

  #after_create :create_revalorisation, :create_allocataire_suivi! #, :create_allocataire!

  after_save :create_allocataire

  has_one_attached :document

  private

  def create_allocataire_suivi!
    if validation_directeur?
      AllocataireSuiviModification.create(allocataire: self.allocataire,
                                          commentaire: "Pension Alimentaire #{self.nom} - #{self.prenom} ##{self.id}",
                                          date_validation: DateTime.now,
                                          dossier_revision: self,
                                          impacte_montant_paiement: true)
    end
  end

  def create_numero_dossier
    if creation?
      annee = Date.today.year
      prefixe = 'A'

      dernier_dossier_ajoute = PensionAlimentaire.where(
          numero_allocataire: numero_allocataire,
      ).order('created_at DESC').first

      if dernier_dossier_ajoute.nil?
        self.numero_dossier = "#{prefixe}/#{numero_allocataire}/#{annee}/01"
      else
        a = dernier_dossier_ajoute.numero_dossier.split('/')
        a[2] = annee
        self.numero_dossier = a.join('/').next
      end
    end
  end

=begin
  def create_allocataire!
    if creation?
      a = numero_dossier.split('/')
      #a.delete_at(2)
      numero = a.join
      if validation_directeur? and not Allocataire.exists?(numero_allocataire: numero)
        allocataire = Allocataire.new(
            numero_allocataire: numero,
            nom: nom,
            prenom: prenom,
            date_naissance: date_naissance,
            categorie: :pension_alimentaire,
            etat: :inactif,
            nombre_epouses: 0,
            nombre_enfants: 0,
            adresse_rue: adresse,
            code_pays: "SN",

            regime: 1,
            age_revolu: 0,

            versement_unique: false,
            date_jouissance: date_jouissance,

            moyenne: 0,
            mois_gratuis: 0,
            points: 0,
            points_base: 0,
            point_minoration: 0,
            pourcentage_majoration: 0,
            point_majoration: 0,
            points_complementaires: 0,
            points_servis: 0,
            montant_imposable: 0,

            moyenne_rg: 0,
            mois_gratuis_rg: 0,
            points_rg: 0,
            points_base_rg: 0,
            pourcentage_minoration_rg: 0,
            point_minoration_rg: 0,
            pourcentage_majoration_rg: 0,
            point_majoration_rg: 0,
            points_complementaires_rg: 0,
            points_servis_rg: 0,
            montant_brut_rg: 0,
            montant_imposable_rg: 0,
            moyenne_rc: 0,
            mois_gratuis_rc: 0,
            points_rc: 0,
            points_base_rc: 0,
            pourcentage_minoration_rc: 0,
            point_minoration_rc: 0,
            pourcentage_majoration_rc: 0,
            point_majoration_rc: 0,
            points_complementaires_rc: 0,
            points_servis_rc: 0,
            montant_brut_rc: 0,
            montant_imposable_rc: 0,
            montant_net: montant,
            montant_minimum_fiscal: 0,
            montant_igr: 0,
            montant_rappel: 0,
            montant_premier_paiement: 0
        )

        allocataire.save
      end
    end
  end
=end

  def create_allocataire
    prefixe = 'PA'
    numero = "#{prefixe}/#{self.numero_allocataire}/01"

    dernier_dossier_ajoute = Allocataire.where(
      numero_allocataire: numero,
    ).order('created_at DESC').first

    unless dernier_dossier_ajoute.nil?
      numero = dernier_dossier_ajoute.numero_allocataire.next
    end

    if validation_directeur? and not Allocataire.exists?(numero_allocataire: numero)
      allocataire = Allocataire.new(
        numero_allocataire: numero,
        nom: nom,
        prenom: prenom,
        date_naissance: date_naissance,
        categorie: Allocataire.categories[:pension_alimentaire],
        etat: :valider,
        nombre_epouses: 0,
        nombre_enfants: 0,
        adresse_rue: adresse,
        code_pays: "SN",

        numero_allocataire_donneur: numero_allocataire,

        regime: 1,
        age_revolu: 0,

        versement_unique: false,
        date_jouissance: date_jouissance,

        moyenne: 0,
        mois_gratuis: 0,
        points: 0,
        points_base: 0,
        point_minoration: 0,
        pourcentage_majoration: 0,
        point_majoration: 0,
        points_complementaires: 0,
        points_servis: 0,
        montant_imposable: 0,

        moyenne_rg: 0,
        mois_gratuis_rg: 0,
        points_rg: 0,
        points_base_rg: 0,
        pourcentage_minoration_rg: 0,
        point_minoration_rg: 0,
        pourcentage_majoration_rg: 0,
        point_majoration_rg: 0,
        points_complementaires_rg: 0,
        points_servis_rg: 0,
        montant_brut_rg: 0,
        montant_imposable_rg: 0,
        moyenne_rc: 0,
        mois_gratuis_rc: 0,
        points_rc: 0,
        points_base_rc: 0,
        pourcentage_minoration_rc: 0,
        point_minoration_rc: 0,
        pourcentage_majoration_rc: 0,
        point_majoration_rc: 0,
        points_complementaires_rc: 0,
        points_servis_rc: 0,
        montant_brut_rc: 0,
        montant_imposable_rc: 0,
        montant_net: montant,
        montant_minimum_fiscal: 0,
        montant_igr: 0,
        montant_rappel: 0,
        montant_premier_paiement: 0
      )

      allocataire.save
    end
  end

  def create_revalorisation
    revaloriserPension = RevaloriserPension.new
    revaloriserPension.montant = -self.montant_versement
    revaloriserPension.type_operation = :a_enlever
    revaloriserPension.type_revalorisation = :pension_alimentaire
    revaloriserPension.date_debut = self.date_jouissance + 1.month
    revaloriserPension.allocataire = self.allocataire
    revaloriserPension.save
  end
end
