class Cip < ApplicationRecord
    belongs_to :ajoute_par, class_name: 'User', foreign_key: :ajoute_par_id, optional: true
    has_one_attached :piece_identite 
    validates :piece_identite, content_type: {in: 'application/pdf', message: "n'est pas un PDF"}, attached: true 
    validates :nin, uniqueness: { message: "Un dossier CIP avec le meme NIN existe déjà" }
    validates :prenom, :nom, :demande_type, :nin, :piece_identite, :observation, :ajoute_par, presence: true
    validates :nin, length: 13..14, allow_blank: true

    
end
