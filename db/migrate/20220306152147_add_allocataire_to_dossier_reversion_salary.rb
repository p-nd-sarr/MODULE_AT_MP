class AddAllocataireToDossierReversionSalary < ActiveRecord::Migration[5.2]
  def change
    add_reference :dossier_reversion_salaries, :allocataire, foreign_key: true
  end
end
