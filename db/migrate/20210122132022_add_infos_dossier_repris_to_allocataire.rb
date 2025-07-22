class AddInfosDossierReprisToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :numero_dossier, :string
    add_column :allocataires, :date_cessation, :date
  end
end
