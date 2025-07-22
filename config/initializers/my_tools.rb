module MyTools
  def get_or_calculate(key)
    return yield
    r = $redis.get(key)
    return r unless r.nil?
    r = yield
    ttl = ((DateTime.now.end_of_day - DateTime.now) * 24 * 60 * 60).to_i
    $redis.setex(key, ttl, r)
    r
  end

  # @param [Integer] numero_trimestre
  def trimestre_to_date(numero_trimestre)
    annee = (numero_trimestre - 646) / 4 + 1990
    trimestre = (numero_trimestre - 2) % 4 + 1
    mois = 3 * trimestre
    Date.new(annee, mois, 1).end_of_month
  end
end

module DateAndTime
  module Calculations
    def beginning_of_bimester
      first_quarter_month = [11, 9, 7, 5, 3, 1].detect { |m| m <= month }
      beginning_of_month.change(month: first_quarter_month)
    end
    alias :at_beginning_of_bimester :beginning_of_bimester

    def end_of_bimester
      last_quarter_month = [2, 4, 6, 8, 10, 12].detect { |m| m >= month }
      beginning_of_month.change(month: last_quarter_month).end_of_month
    end
  end
end

# Rack::Utils.multipart_part_limit = 0
Rack::Utils.multipart_total_part_limit = 30_000
