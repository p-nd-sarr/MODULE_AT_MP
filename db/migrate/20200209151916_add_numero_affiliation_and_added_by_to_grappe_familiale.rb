class AddNumeroAffiliationAndAddedByToGrappeFamiliale < ActiveRecord::Migration[5.2]
  def change
    add_column :enfants, :numero_affiliation, :string
    add_column :conjoints, :numero_affiliation, :string
    add_column :enfants, :ajoute_par_id, :integer
    add_column :conjoints, :ajoute_par_id, :integer
    Conjoint.all.each do |conjoint|
      conjoint.numero_affiliation = conjoint.user.numero_salarie
      conjoint.ajoute_par_id = conjoint.user_id
      conjoint.save
    end
    Enfant.all.each do |enfant|
      enfant.numero_affiliation = enfant.user.numero_salarie
      enfant.ajoute_par_id = enfant.user_id
      enfant.save
    end
  end
end
