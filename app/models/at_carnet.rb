class AtCarnet < ApplicationRecord

  def is_verified?
    carnets = AtVenteCarnet.where(num_employeur: numero_employeur)
    return if carnets.nil?
    carnet = carnets.select { |c| c.numero_carnet.include?(numero_carnet) }
    (not (carnet.count.zero?))
  end
end
