class CreateAdminGesadms < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_gesadms do |t|
      t.string :MATRICULE
      t.string :PRENOM
      t.string :NOM
      t.string :NAISSLIEU
      t.integer :SALAIRE
      t.integer :COTISAT
      t.integer :RESTE
      t.string :NAISSMM
      t.string :NAISSAA
      t.integer :SEXE
      t.integer :NATION
      t.integer :EMPLOI
      t.string :PECMM
      t.string :PECAA
      t.integer :SITUAT
      t.integer :JJPOS
      t.integer :CDQVNB
      t.string :CDQWNB
      t.string :CDDXNB
      t.integer :CDEETAB
      t.integer :CDECARTE
      t.integer :CDBLNB
      t.integer :CDBKNB
      t.timestamps
    end
  end
end
