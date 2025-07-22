class Admin::JourOuvrableAnnuel < ApplicationRecord
    validates :mois, :annee, :mois_en_chiffre, :nombre_jour_ouvrable,
        presence: true
    validate :validate_month, on: :create


    private
    def validate_month
        errors.add(:mois, "Le mois existe déjà pour cette année") if Admin::JourOuvrableAnnuel.where(mois: mois).where(annee: annee).exists?
        errors.add(:mois_en_chiffre, "Le mois existe déjà pour cette année") if Admin::JourOuvrableAnnuel.where(mois_en_chiffre: mois_en_chiffre).where(annee: annee).exists?
    end
end
