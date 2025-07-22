class LoadBareme < ActiveRecord::Migration[5.2]
  def self.up
    # xlsx = Roo::Spreadsheet.open('./data_to_load/BAREMES.xlsx')
    #
    # xlsx.sheet('Feuil1').each_row_streaming(offset: 1) do |row|
    #   regime_id = row[0].value
    #   annee = row[1].value
    #   date_debut = row[2].value
    #   date_fin = row[3].value
    #   taux = row[4].value
    #   plafond = row[5].value
    #   sref = row[6].value
    #   valp = row[7].value
    #   taux_contractuel = row[8].value
    #   b = Admin::Bareme.create(
    #       admin_type_regime_id: regime_id,
    #       periode: 2,
    #       valeur_point: valp,
    #       taux: taux,
    #       plafond_salaire: plafond,
    #       date_debut_validite: date_debut,
    #       date_fin_validite: date_fin,
    #       taux_contractuel: taux_contractuel
    #       )
    # end
  end

  def self.down
    ActiveRecord::Base.connection.truncate(Admin::Bareme.table_name)
  end
end
