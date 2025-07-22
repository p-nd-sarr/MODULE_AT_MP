class AddIdentificationColumnToAtFraisEngages < ActiveRecord::Migration[5.2]
  def change
    add_column :at_frais_engages, :identification, :string
  end
end
