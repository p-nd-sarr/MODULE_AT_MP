class AddValidationGrappeToAtRenteFamille < ActiveRecord::Migration[5.2]
  def change
    add_column :at_rente_familles, :numero_affiliation, :string
  end
end
