class Admin::BaremePension < ApplicationRecord
  enum regime: REGIME

  belongs_to :admin_type_regime, class_name: 'Admin::TypeRegime'

  validates :valeur_point_annuelle, :date_debut_validite, :date_fin_validite, :admin_type_regime_id,
            presence: true
  validates :valeur_point_annuelle, :valeur_point_trimestrielle, :valeur_point_bimestrielle, :valeur_point_mensuelle,
            numericality: true, allow_nil: true

  scope :en_cours, -> { where("date_debut_validite <= ? AND date_fin_validite >= ?", Date.today, Date.today) }
  scope :du, -> (date) { where("date_debut_validite <= ? AND date_fin_validite >= ?", date, date) }

  before_save :set_regime

  def self.valeur_mensuelle_cadre_du(date)
    #(Date.new(1958, 1, 1) .. Date.today).map(&:beginning_of_month).uniq.each{|e| Admin::BaremePension.valeur_mensuelle_cadre_du(e); Admin::BaremePension.valeur_mensuelle_general_du(e) }
    key = "admin_bareme_pension:valeur_point_mensuelle_rc-#{date.strftime("%Y%m")}"

    val = $redis.get(key)

    if val
      return val.to_f
    else
      bareme_pension = Admin::BaremePension.cadre.du(date).last

      if bareme_pension
        vp = bareme_pension.try(:valeur_point_mensuelle) || bareme_pension.valeur_point_annuelle / 12
        if date >= Date.today.beginning_of_year
          $redis.setex(key, 24 * 60 * 60, vp) # 24 heures
        else
          $redis.set(key, vp)
        end
        return vp
      else
        return nil
      end
    end
  end

  def self.valeur_mensuelle_general_du(date)
    key = "admin_bareme_pension:valeur_point_mensuelle_rg-#{date.strftime("%Y%m")}"

    val = $redis.get(key)

    if val
      return val.to_f
    else
      bareme_pension = Admin::BaremePension.general.du(date).last

      if bareme_pension
        vp = bareme_pension.try(:valeur_point_mensuelle) || bareme_pension.valeur_point_annuelle / 12
        if date >= Date.today.beginning_of_year
          $redis.setex(key, 24 * 60 * 60, vp) # 24 heures
        else
          $redis.set(key, vp)
        end
        return vp
      else
        return nil
      end
    end
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

  def self.set_valeur_point_mensuelle_rg
    key = "admin_bareme_pension:valeur_point_mensuelle_rg"
    valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_general_du(Date.today)

    ttl = (2 * 24 * 60 * 60).to_i
    $redis.setex(key, ttl, valeur_point_mensuelle)
  end

  def self.get_valeur_point_mensuelle_rg
    key = "admin_bareme_pension:valeur_point_mensuelle_rg"
    $redis.get(key).to_f
  end

  def self.set_valeur_point_mensuelle_rc
    key = "admin_bareme_pension:valeur_point_mensuelle_rc"
    valeur_point_mensuelle = Admin::BaremePension.valeur_mensuelle_cadre_du(Date.today)

    ttl = (2 * 24 * 60 * 60).to_i
    $redis.setex(key, ttl, valeur_point_mensuelle)
  end

  def self.get_valeur_point_mensuelle_rc
    key = "admin_bareme_pension:valeur_point_mensuelle_rc"
    $redis.get(key).to_f
  end
end
