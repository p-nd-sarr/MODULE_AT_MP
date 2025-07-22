class AddSigleToImmatriculation < ActiveRecord::Migration[5.2]
  def change

    add_column :immatriculations, :sigle, :string
    add_column :immatriculations, :statut_demande, :string

  end
end
