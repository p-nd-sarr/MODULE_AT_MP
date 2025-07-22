class Admin::Bareme < ApplicationRecord
  enum regime: REGIME

  PERIODE = {
      mensuelle: 1,
      annuelle: 2
  }.freeze

  enum periode: PERIODE

  belongs_to :admin_type_regime, class_name: 'Admin::TypeRegime'

  validates :periode, :plafond_salaire, :salaire_reference, :date_debut_validite,
            :date_fin_validite, :admin_type_regime_id,
            presence: true
  validates :plafond_salaire, :salaire_reference,
            numericality: true

  before_save :set_regime

  scope :en_cours, -> { where("date_debut_validite <= ? AND date_fin_validite >= ?", Date.today, Date.today) }
  scope :annee_precedente, -> { where("date_debut_validite <= ? AND date_fin_validite >= ?", Date.today.last_year, Date.today.last_year) }
  scope :du, -> (date) { where("date_debut_validite <= ? AND date_fin_validite >= ?", date, date) }

  def coefficient
    1.0 * (taux_contractuel / 100.0) / salaire_reference
  end

  def set_regime
    if self.admin_type_regime.code == Admin::TypeRegime::GENERAL
      self.regime = :general
    elsif self.admin_type_regime.code == Admin::TypeRegime::CADRE
      self.regime = :cadre
    elsif self.admin_type_regime.code == Admin::TypeRegime::EMPLOYE_DE_MAISON
      self.regime = :employe_de_maison
    end
  end

  def self.salaire_reference_cadre_du(date)
    #(Date.new(1958, 1, 1) .. Date.today).map(&:beginning_of_month).uniq.each{|e| Admin::Bareme.salaire_reference_cadre_du(e); Admin::Bareme.salaire_reference_general_du(e) }
    key = "admin_bareme:salaire_reference_rc-#{date.strftime("%Y%m")}"

    val = $redis.get(key)

    if val
      return val.to_f
    else
      bareme = Admin::Bareme.cadre.du(date).last

      if bareme.try(:salaire_reference)
        if date >= Date.today.beginning_of_year
          $redis.setex(key, 24 * 60 * 60, bareme.salaire_reference) # 24 heures
        else
          $redis.set(key, bareme.salaire_reference)
        end
        return bareme.salaire_reference
      else
        return nil
      end
    end
  end

  def self.salaire_reference_general_du(date)
    key = "admin_bareme:salaire_reference_rg-#{date.strftime("%Y%m")}"

    val = $redis.get(key)

    if val
      return val.to_f
    else
      bareme = Admin::Bareme.general.du(date).last

      if bareme.try(:salaire_reference)
        if date >= Date.today.beginning_of_year
          $redis.setex(key, 24 * 60 * 60, bareme.salaire_reference) # 24 heures
        else
          $redis.set(key, bareme.salaire_reference)
        end
        return bareme.salaire_reference
      else
        return nil
      end
    end
  end

  def self.taux_contractuel_cadre_du(date)
    #(Date.new(1958, 1, 1) .. Date.today).map(&:beginning_of_month).uniq.each{|e| Admin::Bareme.taux_contractuel_cadre_du(e); Admin::Bareme.taux_contractuel_general_du(e) }
    key = "admin_bareme:taux_contractuel_rc-#{date.strftime("%Y%m")}"

    val = $redis.get(key)

    if val
      return val.to_f
    else
      bareme = Admin::Bareme.cadre.du(date).last

      if bareme.try(:taux_contractuel)
        if date >= Date.today.beginning_of_year
          $redis.setex(key, 24 * 60 * 60, bareme.taux_contractuel) # 24 heures
        else
          $redis.set(key, bareme.taux_contractuel)
        end
        return bareme.taux_contractuel
      else
        return nil
      end
    end
  end

  def self.taux_contractuel_general_du(date)
    key = "admin_bareme:taux_contractuel_rg-#{date.strftime("%Y%m")}"

    val = $redis.get(key)

    if val
      return val.to_f
    else
      bareme = Admin::Bareme.general.du(date).last

      if bareme.try(:taux_contractuel)
        if date >= Date.today.beginning_of_year
          $redis.setex(key, 24 * 60 * 60, bareme.taux_contractuel) # 24 heures
        else
          $redis.set(key, bareme.taux_contractuel)
        end
        return bareme.taux_contractuel
      else
        return nil
      end
    end
  end

  def self.plafond_salaire_cadre_du(date)
    #(Date.new(1958, 1, 1) .. Date.today).map(&:beginning_of_month).uniq.each{|e| Admin::Bareme.plafond_salaire_cadre_du(e); Admin::Bareme.plafond_salaire_general_du(e) }
    key = "admin_bareme:plafond_salaire_rc-#{date.strftime("%Y%m")}"

    val = $redis.get(key)

    if val
      return val.to_f
    else
      bareme = Admin::Bareme.cadre.du(date).last

      if bareme.try(:plafond_salaire)
        if date >= Date.today.beginning_of_year
          $redis.setex(key, 24 * 60 * 60, bareme.plafond_salaire) # 24 heures
        else
          $redis.set(key, bareme.plafond_salaire)
        end
        return bareme.plafond_salaire
      else
        return nil
      end
    end
  end

  def self.plafond_salaire_general_du(date)
    key = "admin_bareme:plafond_salaire_rg-#{date.strftime("%Y%m")}"

    val = $redis.get(key)

    if val
      return val.to_f
    else
      bareme = Admin::Bareme.general.du(date).last

      if bareme.try(:plafond_salaire)
        if date >= Date.today.beginning_of_year
          $redis.setex(key, 24 * 60 * 60, bareme.plafond_salaire) # 24 heures
        else
          $redis.set(key, bareme.plafond_salaire)
        end
        return bareme.plafond_salaire
      else
        return nil
      end
    end
  end
end
