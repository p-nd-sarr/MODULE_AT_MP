class CreateTrackings < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'pgcrypto'

    create_table :trackings, id: :uuid do |t|
      t.references :user, foreign_key: true
      t.string :type_requete, limit: 7
      t.string :path, limit: 300
      t.string :path_source, limit: 300
      t.string :ip, limit: 40
      t.string :controller, limit: 100
      t.string :action, limit: 100

      t.timestamps
    end
  end
end
