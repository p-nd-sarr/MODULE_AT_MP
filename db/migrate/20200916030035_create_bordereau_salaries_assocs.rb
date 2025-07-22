class CreateBordereauSalariesAssocs < ActiveRecord::Migration[5.2]
  def change
    create_table :bordereau_salaries_assocs do |t|
      t.references :bordereau_collectif
      t.references :participant

    end
  end
end
