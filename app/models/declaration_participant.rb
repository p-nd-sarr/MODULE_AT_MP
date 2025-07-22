class DeclarationParticipant < ApplicationRecord
  belongs_to :declaration_chargement

  after_create :load_to_psrm

  def load_to_psrm
    return if Psrm::Participant.where("edi_id = ? or matric = ? or ipres_ancien_matric = ?", self.id, self.matric, self.ipres_ancien_matric).exists?

    Psrm::Participant.create(
      matric: self.matric,
      ipres_ancien_matric: self.ipres_ancien_matric,
      css_ancien_matric: self.css_ancien_matric,
      prenom: self.prenom,
      nom: self.nom,
      type_piece: self.type_piece,
      numero_piece: self.numero_piece,
      profession: self.profession,
      emploi: self.emploi,
      regime: self.regime,
      addr: self.addr,
      phone: self.phone,
      date_naissance: self.date_naissance,
      genre: self.genre,
      created_at: Time.now,
      updated_at: Time.now,
      id_employeur: self.id_employeur,
      contrat_en_cours: self.contrat_en_cours,
      date_debut_contrat: self.date_debut_contrat,
      date_fin_contrat: self.date_fin_contrat,
      edi_id: self.id,
    )
  end
end
