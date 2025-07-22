module Activable
  extend ActiveSupport::Concern

  included do
    scope :actifs, -> { where(actif: true) }
    scope :inactifs, -> { where(actif: false) }
  end

  def activer!
    update(actif: true)
  end

  def desactiver!
    update(actif: false)
  end
end
