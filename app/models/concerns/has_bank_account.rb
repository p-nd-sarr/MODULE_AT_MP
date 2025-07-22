module HasBankAccount
  extend ActiveSupport::Concern

  ##
  # colums to add to the table that include this module
  # add_column :table, :admin_banque_agence_id, :integer
  # add_column :table, :compte_bancaire_cle_rib, :string, limit: 2
  # add_column :table, :compte_bancaire_numero_compte, :string, limit: 12
  ##

  included do
    belongs_to :admin_banque_agence, :class_name => 'Admin::BanqueAgence',
               foreign_key: :admin_banque_agence_id,
               optional: true

    validates :admin_banque_agence_id, :compte_bancaire_numero_compte, #:compte_bancaire_cle_rib,
              presence: true,
              if: :virement?,
              on: :create

    #validates :compte_bancaire_numero_compte, length: {is: 12, allow_blank: true}
    #validates :compte_bancaire_cle_rib, length: {is: 2, allow_blank: true}
    #validate :check_rib
  end

  def compte_bancaire_code_swift
    admin_banque_agence.try(:admin_banque).try(:code_swift)
  end

  def compte_bancaire_nom_banque
    admin_banque_agence.try(:admin_banque).try(:nom)
  end

  def compte_bancaire_code_banque
    admin_banque_agence.try(:admin_banque).try(:code)
  end

  def compte_bancaire_code_guichet
    admin_banque_agence.try(:code)
  end

  def rib
    compte_bancaire_numero_compte
    # return nil if admin_banque_agence.nil?
    # "#{compte_bancaire_code_banque} #{compte_bancaire_code_guichet} #{compte_bancaire_numero_compte} #{compte_bancaire_cle_rib}"
  end

  def bank_id
    admin_banque_agence.try(:admin_banque).try(:bank_id)
  end

  def bank_branch_id
    admin_banque_agence.try(:bank_branch_id)
  end

  private

  def check_rib
    return if rib.nil?

    g = compte_bancaire_code_guichet
    c = compte_bancaire_numero_compte
    k = compte_bancaire_cle_rib
    b = compte_bancaire_code_banque.each_char.inject('') do |sum, char|
      char = char.to_i 36
      sum += ((char + 2 ** ((char - 10) / 9)).to_i % 10).to_s
    end

    unless (b + g + c + k).to_i % 97 == 0
      errors.add(:compte_bancaire_cle_rib, "RIB non valide")
    end
  end
end
