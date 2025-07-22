class AddGrossesseToAllocationPrenatale < ActiveRecord::Migration[5.2]
  def self.up
    add_reference :allocation_prenatales, :grossesse, foreign_key: true

    AllocationPrenatale.all.each do |a|
      g = Grossesse.find_or_create_by(dossier_prestation: a.dossier_prestation, date_grossesse: a.debut_grossesse)
      a.update(grossesse_id: g.id)
    end
  end

  def self.down
    remove_reference :allocation_prenatales, :grossesse
  end
end
