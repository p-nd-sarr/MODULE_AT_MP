class SalarieImmatriculation < ApplicationRecord
  require 'csv'
  require 'activerecord-import/base'
  require 'activerecord-import/active_record/adapters/postgresql_adapter'

  belongs_to :user

  belongs_to :admin_convention_collective, optional: true, :class_name => 'Admin::ConventionCollective', foreign_key: :convention_applicable
  belongs_to :admin_profession, optional: true,:class_name => 'Admin::Profession', foreign_key: :profession
  belongs_to :admin_pays_naissance, optional: true,:class_name => 'Admin::Country', foreign_key: :pays_naissance
  belongs_to :admin_pays, optional: true,:class_name => 'Admin::Country', foreign_key: :pays
  belongs_to :admin_pays_delivrance, optional: true,:class_name => 'Admin::Country', foreign_key: :pays_delivrance
  belongs_to :admin_nationalite, optional: true,:class_name => 'Admin::Country', foreign_key: :nationalite

  belongs_to :reprise_region,  optional: true,:class_name => 'Admin::Region', foreign_key: :region
  belongs_to :reprise_departement,  optional: true,:class_name => 'Admin::Departement', foreign_key: :departement
  belongs_to :reprise_ville,  optional: true,:class_name => 'Admin::Ville', foreign_key: :arondissement
  #belongs_to :reprise_ville_naissance,  :class_name => 'Admin::Ville', foreign_key: :ville_naissance
  belongs_to :reprise_commune,  optional: true,:class_name => 'Admin::Commune', foreign_key: :commune
  belongs_to :reprise_quartier, optional: true, :class_name => 'Admin::Quartier', foreign_key: :quartier

  ETAT = {
      actif: 1,
      retrait: 2
  }.freeze

  enum etat: ETAT

  TEMPS_TRAVAIL = {
      tps_plein: 1,
      tps_partiel: 2
  }.freeze

  enum temps_travail: TEMPS_TRAVAIL

  SEXE = {
      homme: 1,
      femme: 2
  }.freeze

  enum sexe: SEXE

  TYPE_PIECE= {
      cdao: 1,
      nin: 2,
      pass: 3
  }.freeze

  enum type_piece: TYPE_PIECE

  ETAT_CIVIL= {
      cel: 0,
      div: 1,
      mar: 2,
      veu: 3
  }.freeze

  enum etat_civil: ETAT_CIVIL

  NATURE_CONTRAT= {
      spe: 0,
      sta: 1,
      cdd: 2,
      cdi: 3,
      jou: 4
  }.freeze

  enum nature_contrat: NATURE_CONTRAT

  def self.my_import(file, user_id)
    rows = CSV.read(file.path, col_sep: ';', headers: :first_row)
    user = User.find(user_id)

    rows.each { |row|
      SalarieImmatriculation.create(
          matricule: row[0],
          nom: row[1],
          prenom: row[2],
          sexe: :row[3],
          etat_civil: :row[4],
          date_naissance: row[5],
          user: user
      )
    }
=begin
    columns = [:matricule, :nom, :prenom, :sexe, :etat_civil, :date_naissance]
    salaries = []
    CSV.foreach(file.path, headers: true) do |row|

      salarie = SalarieImmatriculation.new(
                                          matricule: row[0],
                                          nom: row[1],
                                          prenom: row[2],
                                          sexe: row[3],
                                          etat_civil: row[4],
                                          date_naissance: row[5],
                                          user: user
      )

      salarie.save

      salaries << salarie

      salarie_search = SalarieImmatriculation.find_by_numero_piece(row[5])
      if salarie_search.nil?
        salarie.user = user
        salarie.save
        salaries << SalarieImmatriculation.new(row.to_h)
      end



    end
    SalarieImmatriculation.import salaries, recursive: true
=end
  end

  def est_cadre
    est_cadre?
  end

  def montant_pf
    ([63_000, salaire_contractuel].min * 0.07).round(-1)
  end

  def montant_rg
    ([360_000, salaire_contractuel].min * 0.14).round(-1)
  end

  def montant_rcc
    return 0 unless est_cadre
    ([1_080_000, salaire_contractuel].min * 0.06).round(-1)
  end

  def montant_at(taux_at = 0)
    (salaire_contractuel * (taux_at * 0.01)).round(-1)
  end

  def est_non_cadre
    not est_cadre?
  end

  def tot_sal_ass_css_pf1
    [63_000, salaire_contractuel.round(-1)].min
  end

  def tot_sal_ass_css_atmp1
    [63_000, salaire_contractuel.round(-1)].min
  end

  def tot_sal_ass_ipres_rg1
    [360_000, salaire_contractuel.round(-1)].min
  end

  def tot_sal_ass_ipres_rcc1
    [360_000, salaire_contractuel.round(-1)].min
  end
end
