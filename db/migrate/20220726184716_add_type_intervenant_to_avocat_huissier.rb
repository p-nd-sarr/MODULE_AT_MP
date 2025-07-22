class AddTypeIntervenantToAvocatHuissier < ActiveRecord::Migration[5.2]
  def change
    add_column :avocats_huissiers, :type_intervenant, :integer
  end
end
