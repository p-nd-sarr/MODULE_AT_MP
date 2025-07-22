class Admin::BanqueAgence < ApplicationRecord
  belongs_to :admin_banque, :class_name => 'Admin::Banque'

  validates :nom, :bank_branch_id, :code, :admin_banque_id,
            presence: true

  validates :nom, uniqueness: {scope: :admin_banque, message: "existe déjà pour cette banque"}
  validates :bank_branch_id, :code, uniqueness: true

  def nom_complet
    "#{admin_banque.nom} - #{nom}"
  end
end
