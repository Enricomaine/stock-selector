class Ranking < ApplicationRecord
  def self.current_with_position_diff
    find_by_sql(<<~SQL)
      SELECT r.ticker,
             r.position,
             COALESCE(r.position - l.position, 0) AS dif
        FROM rankings r
        LEFT JOIN rankings l ON l.ticker = r.ticker
                            AND l.created_at::date = (
                              SELECT MAX(created_at::date)
                                FROM rankings
                               WHERE created_at::date < CURRENT_DATE
                            )
       WHERE r.created_at::date = CURRENT_DATE
       ORDER BY r.position ASC
    SQL
  end

  def save_ranking(stocks)
    return if Ranking.where(created_at: Time.zone.today.all_day).exists?

    stocks.each_with_index do |stock, index|
      Ranking.create!(ticker: stock[:ticker], position: index + 1)
    end

    Ranking.where("created_at <= ?", 2.days.ago.end_of_day).delete_all
  end
end
