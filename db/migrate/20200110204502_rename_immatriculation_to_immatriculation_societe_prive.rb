class RenameImmatriculationToImmatriculationSocietePrive < ActiveRecord::Migration[5.2]
  def change

    def self.up
      rename_table :immatriculations, :immatriculation_societe_prives
    end

    def self.down
      rename_table :immatriculation_societe_prives, :immatriculations
    end

  end
end
