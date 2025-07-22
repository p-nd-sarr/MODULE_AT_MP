class ChangeModePaiementTypeFromAllocataire < ActiveRecord::Migration[5.2]
  def self.up
    Allocataire.connection.update("update allocataires set mode_paiement='1' where mode_paiement='virement'")
    Allocataire.connection.update("update allocataires set mode_paiement='2' where mode_paiement='paiement_a_domicile'")
    Allocataire.connection.update("update allocataires set mode_paiement='3' where mode_paiement='mise_a_disposition_bancaire'")
    Allocataire.connection.update("update allocataires set mode_paiement='4' where mode_paiement='carte_ipres'")
    Allocataire.connection.update("update allocataires set mode_paiement='100' where mode_paiement='autres'")

    change_column :allocataires, :mode_paiement, :integer,
                  using: 'mode_paiement::integer'
  end

  def self.down
    change_column :allocataires, :mode_paiement, :string
  end
end
