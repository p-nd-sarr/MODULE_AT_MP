class MissingLigneDeclaration < ApplicationRecord
  ETAT = {
    creation: 1,
    soumis: 2,
    rejeter: 3,
    valide: 4
  }.freeze

  enum etat: ETAT

  MOTIF = {
    aucun: 0,
    deces: 1,
    licenciement_demission: 3,
    retraite: 4,
    mutation: 8
  }.freeze

  enum motif_sortie: MOTIF

  SEXE = {
    homme: 1,
    femme: 2
  }.freeze

  enum sexe: SEXE

  belongs_to :missing_declaration

  belongs_to :type_regime, :class_name => 'Admin::TypeRegime', foreign_key: :regime

  belongs_to :admin_profession, optional: true, :class_name => 'Admin::Profession', foreign_key: :profession_id

  belongs_to :admin_nationalite, optional: true, :class_name => 'Admin::Country', foreign_key: :nationalite_id

  validates :nom, :prenom, :date_entree, :date_sortie, :salaire_reel, :salaire_soumis, presence: true

  validate :validate_date!

  validates :matricule, :presence => true, length: { is: 11 }

  def validate_date!
    return if date_entree.nil?
    return if date_sortie.nil?

    if date_entree > date_sortie
      errors.add(:date_entree, "Ne peut pas être postérieure à la date de sortie (#{I18n.l(date_entree)})")
    end
  end

  def self.my_import(file, declaration_id)
    lignes = []
    MissingLigneDeclaration.transaction do
      begin
        rows = CSV.read(file.path, col_sep: ';', headers: :first_row)
        declaration = MissingDeclaration.find(declaration_id)
        ErrorMissingLigne.where(missing_declaration_id: declaration.id).destroy_all
        code_regime = declaration.regime == "1" ? "GENERAL" : "CADRE"
        regime = Admin::TypeRegime.find_by_code(code_regime)
        rows.each { |row|
          ligne = MissingLigneDeclaration.find_by_matricule(row[0])
          if ligne.nil?
            profession = Admin::Profession.find_by_code(row[11])
            nationalite = Admin::Country.find_by_code(row[12])

            date_entree = Date.parse(row[3])
            date_entree = date_entree.change(:year => Date.parse("01/01/#{ declaration.exercice}").year)
            date_sortie = Date.parse(row[4])
            date_sortie = date_sortie.change(:year => Date.parse("01/01/#{ declaration.exercice}").year)
            ligne = MissingLigneDeclaration.new(
              matricule: row[0],
              nom: row[1],
              prenom: row[2],
              type_regime: regime,
              date_entree: date_entree,
              date_sortie: date_sortie,
              salaire_soumis: row[6],
              salaire_reel: row[7],
              numero_identite: row[8],
              date_naissance: Date.parse(row[9]),
              lieu_naissance: row[10],
              admin_profession: profession,
              admin_nationalite: nationalite,
              sexe: row[13] == "HOMME" ? 1 : 2,
              missing_declaration: declaration,
              etat: :creation
            )

            lignes << ligne
          else
            ErrorMissingLigne.create(
              matricule: row[0],
              nom: row[1],
              prenom: row[2],
              missing_declaration: declaration,
              message: 'Le matricule existe deja'
            )
            raise ActiveRecord::Rollback
            false
          end
        }
        lignes.each do |ligne|
          unless ligne.save
            ErrorMissingLigne.create(
              matricule: ligne.matricule,
              nom: ligne.nom,
              prenom: ligne.prenom,
              missing_declaration: declaration,
              message: 'Erreur : Vérifier les informations de cette ligne de déclaration'
            )
          end
        end
        ErrorMissingLigne.where(missing_declaration_id: declaration.id).destroy_all
        true
      rescue
        false
      end
    end
  end

end
