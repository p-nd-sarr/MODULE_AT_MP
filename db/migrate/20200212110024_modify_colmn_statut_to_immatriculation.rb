class ModifyColmnStatutToImmatriculation < ActiveRecord::Migration[5.2]
  def change

    def self.up
      remove_column :immatriculation_private_societes, :statut_demande

      add_column :immatriculation_private_societes, :statut_demande , :int

    end

    def self.down

      remove_column :immatriculation_private_societes, :statut_demande

      add_column :immatriculation_private_societes, :statut_demande , :string

    end

  end
end
