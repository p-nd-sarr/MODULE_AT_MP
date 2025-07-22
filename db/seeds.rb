# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# u = User.create(prenom: 'Prenom',
#                 nom: 'Nom',
#                 email: 'email',
#                 type_profil: :admin,
#                 telephone: '221770000000',
#                 password: 'Passer123',
#                 sexe: :homme)
#
# u.activer!

require 'csv'

if false
  rows = CSV.read('./data_to_load/numeros_uniques_allocataires.csv', col_sep: ';', headers: :first_row)
  nb = rows.count
  i = 0
  rows.each { |row|
    numero_unique = row[0]
    ancien_numero_ipres = row[1]
    puts "UPDATE " "allocataires" " SET " "numero_allocataire" " = '#{numero_unique}' WHERE " "allocataires" "." "numero_allocataire" " = '#{ancien_numero_ipres}';"
  }
end

if Admin::Agence.all.empty?
  rows = CSV.read('./data_to_load/XXIPRES_CSS_UO_CORRESP_BACKEND.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    type_agence = if row[0] == '81'
                    :ipres
                  else
                    row[0] == '82' ? :css : row[0]
                  end
    Admin::Agence.create(type_agence: type_agence, code: row[1], description_ebs: row[2], code_prest: row[3], description_prest: row[4], code_psrm: row[5], description_psrm: row[6], code_site: row[7])
  }
end

if Admin::Profession.all.empty?
  rows = CSV.read('./data_to_load/Codes_Professions_PSRM.csv', col_sep: ';', headers: :first_row)
  rows.each do |row|
    Admin::Profession.create(code: row[0], description: row[1])
  end
end

if Admin::ConventionCollective.all.empty?
  rows = CSV.read('./data_to_load/Convetion_Collectives_PSRM.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::ConventionCollective.create(code: row[0], description: row[1])
  }
end

if Admin::SecteurActivite.all.empty?
  rows = CSV.read('./data_to_load/Secteurs_Activites_PSRM.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::SecteurActivite.create(description: row[0])
  }
end

if Admin::ActivitePrincipale.all.empty?
  rows = CSV.read('./data_to_load/Activites_Principales_PSRM.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    description_secteur = row[2]
    secteur = Admin::SecteurActivite.find_or_create_by(description: description_secteur)
    Admin::ActivitePrincipale.create(admin_secteur_activite: secteur, description: row[0])
  }
end

if Admin::TypeEmployeur.all.empty?
  rows = CSV.read('./data_to_load/Type_Employeurs_PSRM.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::TypeEmployeur.create(code: row[0], description: row[1])
  }
end

if Admin::Profession.all.empty?
  rows = CSV.read('./data_to_load/Codes_Professions_PSRM.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::Profession.create(code: row[0], description: row[1])
  }
end

if Admin::StatutJuridique.all.empty?
  rows = CSV.read('./data_to_load/Code_Juridiques_PSRM.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::StatutJuridique.create(code: row[0], description: row[1])
  }
end

if Admin::TypeContratSalarie.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet('Type de contrat salariés').each_row_streaming do |row|
    Admin::TypeContratSalarie.create(code: row[2], description: row[3])
  end
end

if Admin::TypeRegime.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet('Types de regime').each_row_streaming do |row|
    Admin::TypeRegime.create(code: row[2], description: row[3])
  end
end

if Admin::Site.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet('Liste des sites').each_row_streaming do |row|
    Admin::Site.create(code: row[2], description: row[3])
  end
end

if Admin::TempsTravail.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet('Temps de travail').each_row_streaming do |row|
    Admin::TempsTravail.create(code: row[2], description: row[3])
  end
end

if Admin::MouvementTravail.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet('Mouvement de travail').each_row_streaming(offset: 1) do |row|
    Admin::MouvementTravail.create(code: row[0], description: row[1])
  end
end

if Admin::MouvementTravailFin.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet('Mouvement de travail Sortie').each_row_streaming(offset: 1) do |row|
    Admin::MouvementTravailFin.create(code: row[0], description: row[1])
  end
end

if Admin::MotifSortie.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet('Motifs de sortie').each_row_streaming do |row|
    Admin::MotifSortie.create(code: row[2], description: row[3])
  end
end

if Admin::TypeStatutJuridique.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet('Type statut juridiques').each_row_streaming do |row|
    Admin::TypeStatutJuridique.create(code: row[2], description: row[3])
  end
end

if Admin::TypeEtatCivil.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet("Type d'état civil").each_row_streaming do |row|
    Admin::TypeEtatCivil.create(code: row[2], description: row[3])
  end
end

if Admin::TypeEtablissementPublique.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet("Type d'établissement publique").each_row_streaming do |row|
    Admin::TypeEtablissementPublique.create(code: row[2], description: row[3])
  end
end

if Admin::TypeEtablissementDiplomatique.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet("Type d'établissement diplomatiq").each_row_streaming do |row|
    Admin::TypeEtablissementDiplomatique.create(code: row[2], description: row[3])
  end
end

if Admin::TypeEtablissement.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet("Types d'établissement").each_row_streaming do |row|
    Admin::TypeEtablissement.create(code: row[2], description: row[3])
  end
end

if Admin::TypePieceIdentification.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/PARAMETRES_AVEC_VALEURS_VF.xlsx')
  xlsx.sheet("Type de Pièce d'identification").each_row_streaming do |row|
    Admin::TypePieceIdentification.create(code: row[1], description: row[2])
  end
end

if Admin::TypeEmployeur.all.empty?
  rows = CSV.read('./data_to_load/XXIPRES_CSS_UO_CORRESP_BACKEND.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::Agence.create(type_agence: row[0], code: row[1], description_ebs: row[2], code_prest: row[3], description_prest: row[4], code_psrm: row[5], description_psrm: row[6], code_site: row[7])
  }
end

if Admin::ComposantSalaire.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/CODE_PRIMES_SALAIRES.xlsx')
  xlsx.sheet('Feuil1').each_row_streaming(offset: 1) do |row|
    prise = row[2].value == 'OUI'
    Admin::ComposantSalaire.create(code: row[0], designation: row[1], prise_en_compte: prise)
  end
end

if BaremeImpot.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/bareme_ir.xlsx')
  xlsx.sheet('Feuil1').each_row_streaming(offset: 1) do |row|
    revenu_brut = row[0].value
    trimf = row[1].value
    un = row[2].value
    un_cinq = row[3].value
    deux = row[4].value
    deux_cinq = row[5].value
    trois = row[6].value
    trois_cinq = row[7].value
    quatre = row[8].value
    quatre_cinq = row[9].value
    cinq = row[10].value
    BaremeImpot.create(
      revenu_brut: revenu_brut,
      trimf: trimf,
      un: un,
      un_cinq: un_cinq,
      deux: deux,
      deux_cinq: deux_cinq,
      trois: trois,
      trois_cinq: trois_cinq,
      quatre: quatre,
      quatre_cinq: quatre_cinq,
      cinq: cinq
    )
  end
end

if Admin::Bareme.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/BaremeCalculdePoints.xlsx')
  xlsx.sheet('Calcul de points Format').each_row_streaming(offset: 1) do |row|
    code_regime = row[0].value
    date_debut = row[1].value
    date_fin = row[2].value
    sref = row[3].value
    taux_contractuel = row[4].value
    plafond = row[6].value

    admin_type_regime = Admin::TypeRegime.find_by(code: code_regime)

    Admin::Bareme.create(
      admin_type_regime: admin_type_regime,
      periode: 2,
      plafond_salaire: plafond,
      date_debut_validite: date_debut,
      date_fin_validite: date_fin,
      taux_contractuel: taux_contractuel,
      salaire_reference: sref
    )
  end
end

if Admin::BaremePension.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/BaremeCalculdePoints.xlsx')
  xlsx.sheet('Calcul de la pension Format').each_row_streaming(offset: 1) do |row|
    code_regime = row[0].value
    date_debut_validite = row[1].value
    date_fin_validite = row[2].value
    valeur_point_annuelle = row[3].value
    valeur_point_trimestrielle = row[4].try(:value)
    valeur_point_bimestrielle = row[5].try(:value)
    valeur_point_mensuelle = row[6].try(:value)

    admin_type_regime = Admin::TypeRegime.find_by(code: code_regime)

    a = Admin::BaremePension.create(
      admin_type_regime: admin_type_regime,
      date_debut_validite: date_debut_validite,
      date_fin_validite: date_fin_validite,
      valeur_point_annuelle: valeur_point_annuelle,
      valeur_point_trimestrielle: (valeur_point_trimestrielle == 'NA' ? nil : valeur_point_trimestrielle),
      valeur_point_bimestrielle: (valeur_point_bimestrielle == 'NA' ? nil : valeur_point_bimestrielle),
      valeur_point_mensuelle: (valeur_point_mensuelle == 'NA' ? nil : valeur_point_mensuelle),
    )

    puts a.errors.messages
  end
end

if Admin::LocaliteGrappe.all.empty?
  rows = CSV.read('./data_to_load/localite.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::LocaliteGrappe.create(code_pays: row[0], code_localite: row[1], localite: row[2])
  }
end

if Admin::ComptaNaturePrestation.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/IPRES_CSS_NATURES_PRESTATIONS.xlsx')
  xlsx.sheet("Feuil1").each_row_streaming(offset: 1) do |row|
    code = row[2]
    libelle = row[1]
    entite = row[3].try(:value).try(:downcase)
    branche = row[4].try(:value).try(:downcase)

    unless code.nil?
      Admin::ComptaNaturePrestation.create(
        code: code,
        libelle: libelle,
        entite: entite,
        branche: branche
      )
    end
  end
end

if Admin::Country.all.empty?
  rows = CSV.read('./data_to_load/Codes_Pays.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::Country.create(code: row[0], description: row[1])
  }
end

if Admin::Region.all.empty?
  rows = CSV.read('./data_to_load/REGION.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    Admin::Region.create(
      id: row[0],
      designation: row[1],
      code: row[2],
      admin_country_id: Admin::Country.find_by(code: row[3]).try(:id),
    )
  }
end

if Admin::Departement.all.empty?
  rows = CSV.read('./data_to_load/DEPARTEMENT.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    d = Admin::Departement.create(
      id: row[0],
      admin_region_id: row[1],
      designation: row[2],
      code: row[3],
    )
  }
end

if Admin::Ville.all.empty?
  rows = CSV.read('./data_to_load/VILLE.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    d = Admin::Ville.create(
      id: row[0],
      admin_departement_id: row[2],
      code: row[3],
      designation: row[1],
    )
  }
end

if Admin::Commune.all.empty?
  rows = CSV.read('./data_to_load/COMMUNES.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    d = Admin::Commune.create(
      id: row[0],
      admin_ville_id: row[1],
      code: row[3],
      designation: row[2],
    )
  }
end

if Admin::Quartier.all.empty?
  rows = CSV.read('./data_to_load/QUARTIER.csv', col_sep: ';', headers: :first_row)
  rows.each { |row|
    d = Admin::Quartier.create(
      id: row[0],
      admin_commune_id: row[3],
      code: row[2],
      designation: row[1],
    )
  }
end

if Admin::SalaireAnnuel.all.empty?
  rows = CSV.read('./data_to_load/salaire_annuel.csv', col_sep: ',', headers: :first_row)
  rows.each { |row|
    d = Admin::SalaireAnnuel.create(
      annee: row[0],
      coefficient: row[1],
      date_effet: row[2],
      date_reval: row[3],
      plancher: row[4],
      plafond: row[5],

    )
  }
end

if Admin::Rente.all.empty?
  rows = CSV.read('./data_to_load/tableau_correspond_rente.csv', col_sep: ',', headers: :first_row)
  rows.each { |row|
    d = Admin::Rente.create(
      age: row[0],
      prix: row[1],
    )
  }
end

=begin
if Admin::Banque.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/banques.xlsx')
  xlsx.sheet("Banque").each_row_streaming do |row|
    Admin::Banque.create(code: row[0], description: row[1])
  end
end
=end

if MissingDeclaration.all.empty?
  puts "...chargement..."
  date = DateTime.now
  xlsx = Roo::Spreadsheet.open('./data_to_load/declarations_manquantes.xlsx')
  xlsx.sheet("DECLARATIONS").each_row_streaming do |row|
    MissingDeclaration.create(numero_ipres: row[0],
                              exercice: row[1],
                              regime: row[2],
                              agence_ipres: row[3],
                              versement1: row[4],
                              versement2: row[5],
                              versement3: row[6],
                              versement4: row[7],
                              agence_css: row[8],
                              date_immatriculation_css: row[9])
  end

  puts " debut traitement #{date} - fin traitement : #{DateTime.now}"
end



=begin
#Admin::ComposantSalaire
if AtCodePrimeSalaire.all.empty?
  xlsx = Roo::Spreadsheet.open('./data_to_load/CODE_PRIMES_SALAIRES.xlsx')
  xlsx.sheet('Feuil1').each_row_streaming(offset: 1) do |row|
    prise = row[2].value == 'OUI'
    AtCodePrimeSalaire.create(code: row[0], designation: row[1], prise_en_compte: prise)
  end
end
=end

if Admin::Etablissement.all.empty?
  puts "...chargement..."
  rows = CSV.read('./data_to_load/etablissements.csv', col_sep: ',', headers: :first_row)
  rows.each { |row|
    d = Admin::Etablissement.create(
      code: row[0],
      name: row[1],
    )
  }
end

