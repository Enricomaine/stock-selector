class Ranking < ApplicationRecord
  def self.current_with_position_diff(category_type)
    category_type = category_type.to_i

    find_by_sql(<<~SQL)
      SELECT r.ticker,
             r.position,
             COALESCE(r.position - l.position, 0) AS dif
        FROM rankings r
        LEFT JOIN rankings l ON l.ticker = r.ticker
                            AND l.category_type = r.category_type
                            AND l.created_at::date = (
                              SELECT MAX(created_at::date)
                                FROM rankings
                               WHERE category_type = #{category_type}
                                 AND created_at::date < CURRENT_DATE
                            )
       WHERE r.created_at::date = CURRENT_DATE
         AND r.category_type = #{category_type}
       ORDER BY r.position ASC
    SQL
  end

  def save_ranking(stocks, category_type)
    return if stocks.blank?

    category_type = category_type.to_i

    return if Ranking.where(category_type: category_type, created_at: Time.zone.today.all_day).exists?

    stocks.each_with_index do |stock, index|
      Ranking.create!(ticker: stock[:ticker], position: index + 1, category_type: category_type)
    end

    Ranking.where(category_type: category_type)
           .where("created_at <= ?", 2.days.ago.end_of_day)
           .delete_all
  end
end
