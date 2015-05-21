module Concern::Model::Programs
  extend ActiveSupport::Concern

  def episode_years
    episodes.select("DISTINCT YEAR(air_date) AS air_year")
      .where.not(air_date: nil).order("air_year DESC").map(&:air_year)
  end

  def episode_months year
    beginning_of_year = Time.parse("#{year}-01-01").beginning_of_year
    end_of_year       = Time.parse("#{year}-01-01").end_of_year
    episodes.select("DISTINCT DATE_FORMAT(air_date, '%M') AS air_month")
      .where.not(air_date: nil)
      .where(air_date: beginning_of_year..end_of_year)
      .order("air_date DESC")
      .map(&:air_month)
  end
end