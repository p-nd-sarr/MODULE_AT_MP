class AddRappelAugmentationEnvoyeToAllocataire < ActiveRecord::Migration[5.2]
  def change
    add_column :allocataires, :rappel_augmentation_envoye, :boolean, default: false
  end
end
