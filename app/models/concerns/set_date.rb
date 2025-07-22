module SetDate
  extend ActiveSupport::Concern

  def get_last_month_of_trimestre(trimestre)
    trimestre.to_i * 3
  end

  def set_period_for_allocation_f(trimestre, annee)
    month = get_last_month_of_trimestre(trimestre)
    return nil if annee.nil? or month.nil?
    date = Date.new(annee, month, 1)
    date.change(day: date.end_of_month.day)
  end

  def find_quarter(month)
    case month
    when 1, 2, 3 then
      1
    when 4, 5, 6 then
      2
    when 7, 8, 9 then
      3
    when 10, 11, 12 then
      4
    else
      nil
    end
  end

end
